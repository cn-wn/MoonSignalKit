///|
/// Errors reported by the intentionally small, dependency-free telemetry CSV reader.
///
/// The format is two columns: `time,value`. Quoted fields and locale-specific
/// numeric formats are intentionally out of scope for a portable core library.
pub(all) enum CsvError {
  EmptyInput
  MissingColumns(Int)
  InvalidTime(Int)
  InvalidValue(Int)
} derive(Debug, Eq)

///|
/// Exports a series as portable UTF-8 CSV with a `time,value` header.
pub fn Series::to_csv(self : Series) -> String {
  let mut output = "time,value\n"
  for i = 0; i < self.samples.length(); i = i + 1 {
    let sample = self.samples[i]
    output = output + "\{sample.time},\{sample.value}"
    if i + 1 < self.samples.length() {
      output = output + "\n"
    }
  }
  output
}

///|
/// Imports a two-column `time,value` CSV document.
///
/// Empty lines are ignored. The first non-empty row is treated as a header when
/// `has_header` is true, which is the default and matches `Series::to_csv`.
pub fn Series::from_csv(
  name : String,
  csv : String,
  has_header? : Bool = true,
) -> Result[Series, CsvError] {
  let lines = csv.split("\n").to_array()
  let samples : Array[Sample] = []
  let mut saw_data = false
  let mut header_pending = has_header
  for i = 0; i < lines.length(); i = i + 1 {
    let row = lines[i].to_owned().trim()
    if row == "" {
      continue
    }
    if header_pending {
      header_pending = false
      continue
    }
    saw_data = true
    let columns = row.split(",").to_array()
    if columns.length() < 2 {
      return Err(MissingColumns(i + 1))
    }
    let time = @string.parse_int(columns[0]) catch {
      _ => return Err(InvalidTime(i + 1))
    }
    let value = @string.parse_double(columns[1]) catch {
      _ => return Err(InvalidValue(i + 1))
    }
    samples.push(Sample::new(time, value))
  }
  if !saw_data {
    Err(EmptyInput)
  } else {
    Ok(Series::new(name, samples))
  }
}
