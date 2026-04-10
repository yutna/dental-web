module Dental
  module MasterData
    class RuntimePricingResolver < Dental::BaseUseCase
      def call(item:, eligibility_code:, price_context: :opd, at: Date.current)
        coverage = find_coverage(item, eligibility_code: eligibility_code, at: at)
        return from_coverage(item, coverage, price_context: price_context) if coverage

        from_master(item, price_context: price_context)
      end

      private

      def find_coverage(item, eligibility_code:, at:)
        scope = item.coverages.active.where(eligibility_code: eligibility_code.to_s)

        scope.find do |row|
          row.effective_on?(at)
        end
      end

      def from_coverage(item, coverage, price_context:)
        payload = {
          "item_type" => item.class.name,
          "item_id" => item.id,
          "eligibility_code" => coverage.eligibility_code,
          "source" => "coverage",
          "copay_amount" => coverage.copay_amount&.to_f,
          "copay_percent" => coverage.copay_percent&.to_f
        }

        payload["price"] = if coverage.is_a?(DentalProcedureItemCoverage)
          price_context.to_s == "ipd" ? coverage.price_ipd.to_f : coverage.price_opd.to_f
        else
          coverage.unit_price.to_f
        end

        success(payload: payload)
      end

      def from_master(item, price_context:)
        payload = {
          "item_type" => item.class.name,
          "item_id" => item.id,
          "source" => "master_fallback",
          "copay_amount" => nil,
          "copay_percent" => nil
        }

        payload["price"] = if item.is_a?(DentalProcedureItem)
          price_context.to_s == "ipd" ? item.price_ipd.to_f : item.price_opd.to_f
        else
          item.unit_price.to_f
        end

        success(payload: payload)
      end
    end
  end
end
