require "rails_helper"

RSpec.describe DentalUsageRecord, type: :model do
  def build_usage(overrides = {})
    DentalUsageRecord.new({
      usage_id: "USAGE-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      item_type: "medication",
      item_code: "MED-100",
      item_name: "Lidocaine 2%",
      unit: "vial",
      requested_quantity: 5,
      status: "pending_deduct",
      actor_id: "ACTOR-001"
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with complete attributes" do
      record = build_usage
      expect(record).to be_valid
    end

    it "requires usage_id" do
      record = build_usage(usage_id: nil)
      expect(record).not_to be_valid
      expect(record.errors[:usage_id]).to include("can't be blank")
    end

    it "enforces unique usage_id" do
      build_usage(usage_id: "USAGE-DUP").save!
      dup = build_usage(usage_id: "USAGE-DUP")
      expect(dup).not_to be_valid
      expect(dup.errors[:usage_id]).to include("has already been taken")
    end

    it "requires visit_id" do
      record = build_usage(visit_id: nil)
      expect(record).not_to be_valid
    end

    it "requires item_type in allowed values" do
      record = build_usage(item_type: "invalid")
      expect(record).not_to be_valid
      expect(record.errors[:item_type]).to include("is not included in the list")
    end

    it "requires requested_quantity > 0" do
      record = build_usage(requested_quantity: 0)
      expect(record).not_to be_valid
    end

    it "requires status in allowed values" do
      record = build_usage(status: "bogus")
      expect(record).not_to be_valid
    end

    it "requires void_reason when voided" do
      record = build_usage(voided_at: Time.current, void_reason: nil)
      expect(record).not_to be_valid
      expect(record.errors[:void_reason]).to be_present
    end

    it "accepts supply as item_type" do
      record = build_usage(item_type: "supply")
      expect(record).to be_valid
    end
  end

  describe "scopes" do
    before do
      build_usage(usage_id: "USAGE-P1", status: "pending_deduct").save!
      build_usage(usage_id: "USAGE-D1", status: "deducted", deducted_quantity: 5, movement_ref: "MOV-1", deducted_at: Time.current).save!
      build_usage(usage_id: "USAGE-F1", status: "failed", deduct_error: "INSUFFICIENT_STOCK", failed_at: Time.current).save!
    end

    it ".pending returns pending_deduct records" do
      expect(DentalUsageRecord.pending.pluck(:usage_id)).to eq([ "USAGE-P1" ])
    end

    it ".deducted returns deducted records" do
      expect(DentalUsageRecord.deducted.pluck(:usage_id)).to eq([ "USAGE-D1" ])
    end

    it ".failed returns failed records" do
      expect(DentalUsageRecord.failed.pluck(:usage_id)).to eq([ "USAGE-F1" ])
    end

    it ".for_visit filters by visit_id" do
      build_usage(usage_id: "USAGE-OTHER", visit_id: "VISIT-OTHER").save!
      expect(DentalUsageRecord.for_visit("VISIT-001").count).to eq(3)
    end
  end

  describe "state transitions" do
    describe "#mark_deducted!" do
      it "transitions from pending_deduct to deducted" do
        record = build_usage
        record.save!

        record.mark_deducted!(movement_ref: "MOV-OUT-001")

        expect(record.reload).to be_deducted
        expect(record.movement_ref).to eq("MOV-OUT-001")
        expect(record.deducted_quantity).to eq(5)
        expect(record.deducted_at).to be_present
      end

      it "transitions from failed to deducted on retry" do
        record = build_usage(status: "failed", deduct_error: "err", failed_at: Time.current)
        record.save!

        record.mark_deducted!(movement_ref: "MOV-OUT-002", quantity: 3)

        expect(record.reload).to be_deducted
        expect(record.deducted_quantity).to eq(3)
        expect(record.deduct_error).to be_nil
      end

      it "raises InvalidTransition from deducted" do
        record = build_usage(status: "deducted", deducted_quantity: 5, movement_ref: "MOV-1", deducted_at: Time.current)
        record.save!

        expect { record.mark_deducted!(movement_ref: "MOV-2") }
          .to raise_error(Dental::Errors::InvalidTransition)
      end
    end

    describe "#mark_failed!" do
      it "transitions from pending_deduct to failed" do
        record = build_usage
        record.save!

        record.mark_failed!(error_message: "INSUFFICIENT_STOCK")

        expect(record.reload).to be_failed
        expect(record.deduct_error).to eq("INSUFFICIENT_STOCK")
        expect(record.failed_at).to be_present
      end

      it "raises InvalidTransition from deducted" do
        record = build_usage(status: "deducted", deducted_quantity: 5, movement_ref: "MOV-1", deducted_at: Time.current)
        record.save!

        expect { record.mark_failed!(error_message: "err") }
          .to raise_error(Dental::Errors::InvalidTransition)
      end
    end

    describe "#mark_pending_for_retry!" do
      it "transitions from failed back to pending_deduct" do
        record = build_usage(status: "failed", deduct_error: "err", failed_at: Time.current)
        record.save!

        record.mark_pending_for_retry!

        expect(record.reload).to be_pending_deduct
        expect(record.deduct_error).to be_nil
        expect(record.failed_at).to be_nil
      end

      it "raises InvalidTransition from pending_deduct" do
        record = build_usage
        record.save!

        expect { record.mark_pending_for_retry! }
          .to raise_error(Dental::Errors::InvalidTransition)
      end
    end

    describe "#void!" do
      it "marks record as voided with reason" do
        record = build_usage
        record.save!

        record.void!(reason: "clinical post voided")

        expect(record.reload).to be_voided
        expect(record.void_reason).to eq("clinical post voided")
      end

      it "raises GuardViolation when already voided" do
        record = build_usage(voided_at: Time.current, void_reason: "already")
        record.save!

        expect { record.void!(reason: "again") }
          .to raise_error(Dental::Errors::GuardViolation)
      end
    end
  end
end
