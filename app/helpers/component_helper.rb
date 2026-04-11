module ComponentHelper
  # Build column definitions for the data table component.
  #
  #   data_table_column(:name, "Patient name", sortable: true)
  #   data_table_column(:amount, "Amount", align: "right")
  def data_table_column(key, label, sortable: false, align: "left", **extra)
    { key: key.to_sym, label:, sortable:, align: }.merge(extra)
  end
end
