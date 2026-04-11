module Dental
  module SupplyCosting
    class PostStockMovement < BaseUseCase
      def call(item_type:, item_code:, direction:, quantity:, unit:, source:, reference_type: nil, reference_id: nil, actor_id: nil, note: nil)
        existing = find_existing(reference_type, reference_id, direction)
        return { movement: existing, created: false } if existing

        movement_ref = generate_movement_ref(direction)

        movement = DentalStockMovement.create!(
          movement_ref: movement_ref,
          item_type: item_type,
          item_code: item_code,
          direction: direction,
          quantity: quantity,
          unit: unit,
          source: source,
          reference_type: reference_type,
          reference_id: reference_id,
          actor_id: actor_id,
          note: note
        )

        { movement: movement, created: true }
      end

      private

      def find_existing(reference_type, reference_id, direction)
        return nil if reference_type.blank? || reference_id.blank?

        DentalStockMovement.find_by(
          reference_type: reference_type,
          reference_id: reference_id,
          direction: direction
        )
      end

      def generate_movement_ref(direction)
        prefix = direction == "out" ? "MOV-OUT" : "MOV-IN"
        "#{prefix}-#{SecureRandom.hex(4).upcase}"
      end
    end
  end
end
