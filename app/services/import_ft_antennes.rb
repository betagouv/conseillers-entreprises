class ImportFtAntennes

  # TODO
  # - validation unique safir_code

  def initialize(input, options = {})
    @input = input
    @options = options
  end

  def import
    file = File.read(Rails.root.join('tmp', 'FT_Ref agences enrichi.csv'))
    csv = open_with_best_separator(file)
    if csv.is_a? CSV::MalformedCSVError
      raise CsvImport::MalformedCSVError
    end

    rows = csv.map(&:to_h)
    unreachable = []
    rows.each do |row|
      name = row["dc_lbllong"]
      antennes = base_antennes.search_by_name(name)
      if antennes.size == 1
        antenne = antennes.first
        antenne.update(code_safir: row["kc_unitesafir"]) if antenne.code_safir.blank?
      else
        unreachable << [row["kc_unitesafir"], name]
      end
    end
    p "Unreachable: #{unreachable.size}"
    pp unreachable
  end

  private

  def base_antennes
    Institution.find_by(slug: 'france-travail-pro').antennes.active
  end

  def open_with_separator(input, col_sep)
    squish_converter = lambda { |header| header.squish }
    begin
      common_options = { headers: true, header_converters: squish_converter, col_sep: col_sep, skip_blanks: true, skip_lines: /^(?:,\s*)+$/ }
      if input.respond_to?(:open)
        # Unfortunately, CSV::read only takes files…
        # … and CSV::new takes strings or IO, but the IO needs to be already open.
        # @input is a file:
        CSV.read(input, **common_options)
      else
        # @input is a string:
        CSV.new(input, **common_options).read
      end
    rescue CSV::MalformedCSVError => e
      return e
    end
  end

  def open_with_best_separator(input)
    separators = %w[, ;]
    attempted = separators.map { |separator| open_with_separator(input, separator) }

    opened_files = attempted.filter { |csv| !csv.is_a? CSV::MalformedCSVError }
    return attempted.first if opened_files.empty?

    # Find the separator that find the most headers
    best_index = opened_files.map { |x| x.headers.count }.each_with_index.max.second
    opened_files[best_index]
  end
end
