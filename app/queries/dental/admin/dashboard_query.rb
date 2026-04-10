module Dental
  module Admin
    class DashboardQuery < BaseQuery
      def call
        counts = {
          procedure_groups: DentalProcedureGroup.count,
          procedure_items: DentalProcedureItem.count,
          medication_profiles: DentalMedicationProfile.count,
          supply_categories: DentalSupplyCategory.count,
          supply_items: DentalSupplyItem.count,
          tooth_references: DentalToothReference.count,
          surface_references: DentalToothSurfaceReference.count,
          root_references: DentalToothRootReference.count,
          piece_references: DentalToothPieceReference.count,
          image_type_references: DentalImageTypeReference.count
        }

        {
          totals: counts,
          summary: {
            master_resources: counts.values.sum,
            active_items: active_count,
            pending_approvals: 0,
            sync_warnings: 0
          }
        }
      end

      private

      def active_count
        DentalProcedureGroup.active.count +
          DentalProcedureItem.active.count +
          DentalMedicationProfile.active.count +
          DentalSupplyCategory.active.count +
          DentalSupplyItem.active.count +
          DentalToothReference.active.count +
          DentalToothSurfaceReference.active.count +
          DentalToothRootReference.active.count +
          DentalToothPieceReference.active.count +
          DentalImageTypeReference.active.count
      end
    end
  end
end
