#
# Set of helper methods to generate Arel clauses to assist with
# translations.
#
module TranslationService
  #
  # model - model with the translated field
  # locales - array of languages
  # column - the sort column
  #
  # Returns a subquery with id and sort_field
  #
  # p =  Arel::Table.new(ProgrammeItem.table_name)
  # query = p.project(Arel.star)
  # a = TranslationService.sort_by_column
  # (query, ProgrammeItem, [:en, :fr], 'title', 'programme_item_id')
  # TranslationService.sort_by_column
  # (query, ProgrammeItem, [:en, :fr], 'title', 'programme_item_id')
  def self.sort_by_column(
    query:,
    model:,
    column:,
    id_column:,
    sort_order: 'asc',
    locales: nil
  )
    # If locales aren't passed, set them from the site_languages.
    # If the current locale is in the list of site locales, pluck it and
    # set it first in the array so that records are sorted correctly in the
    # locale you are viewing them in
    locales ||= UISettingsService.site_languages
    if I18n.locale && locales.include?(I18n.locale.to_s)
      locales.delete(I18n.locale.to_s)
      locales.unshift(I18n.locale.to_s)
    end

    src_table = Arel::Table.new(model.table_name)
    sort_table = translatable_join(model, locales, column, id_column)
                 .as('sort_table')

    query.join(
      sort_table
    ).on(
      sort_table[id_column].eq(src_table[:id])
    ).order(
      if sort_order == 'asc'
        generate_order_clause(sort_table, column, locales).asc
      else
        generate_order_clause(sort_table, column, locales).desc
      end
    )
  end

  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.generate_order_clause(table, column, locales)
    if locales.length == 1
      column + '_' + locales[0].to_s
    elsif locales.length == 2
      if_sel_col(
        table,
        column + '_' + locales[0].to_s,
        column + '_' + locales[1].to_s
      )
    elsif locales.length > 2
      if_sel_col_sub(
        table,
        column + '_' + locales[0].to_s,
        generate_order_clause(
          table,
          column,
          locales.slice(1, locales.length - 1)
        )
      )
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.translatable_join(model, locales, column, id_column)
    #
    table_name = model.table_name.singularize + '_translations'
    table = Arel::Table.new(table_name)
    select_fields = []

    locales.each do |locale|
      select_fields << group_concat_fn(
        if_fn(table, locale, column)
      ).as(column + '_' + locale.to_s)
    end

    table.project(
      table[id_column], select_fields
    ).group(
      table[id_column]
    )
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  #
  def self.group_concat_fn(str)
    Arel::Nodes::NamedFunction.new(
      'GROUP_CONCAT',
      [str]
    )
  end

  #
  def self.if_fn(table, locale, column)
    Arel::Nodes::NamedFunction.new(
      'IF',
      [
        table[:locale].eq(locale),
        table[column],
        Arel::Nodes::SqlLiteral.new('null')
      ]
    )
  end

  #
  def self.if_sel_col(table, column1, column2)
    Arel::Nodes::NamedFunction.new(
      'IF',
      [
        table[column1].not_eq(nil),
        table[column1],
        table[column2]
      ]
    )
  end

  def self.if_sel_col_sub(table, column1, column2)
    Arel::Nodes::NamedFunction.new(
      'IF',
      [
        table[column1].not_eq(nil),
        table[column1],
        column2
      ]
    )
  end
end
