import gleam/dict.{type Dict}
import gleam/list
import gleam/string
import simplifile

pub fn from_index(index: Int, domains: Dict(Int, String)) -> String {
  let n = domains |> dict.size
  let new_index = case index < 0 {
    False -> index % n
    True -> {
      { n + index } % n
    }
  }
  case domains |> dict.get(new_index) {
    Ok(domain) -> domain
    Error(_) -> "https://lukaswerner.com"
  }
}

pub fn parse_domain_file(
  from: String,
) -> Result(#(Dict(Int, String), Dict(String, Int)), simplifile.FileError) {
  case from |> simplifile.read {
    Error(err) -> Error(err)
    Ok(content) -> {
      let host_parts =
        content
        |> string.split("\n")
        |> list.filter(fn(s: String) -> Bool { s |> string.length > 0 })
      let indexes =
        host_parts |> list.index_map(fn(x, i) { #(i, x) }) |> dict.from_list
      let domains =
        host_parts |> list.index_map(fn(x, i) { #(x, i) }) |> dict.from_list
      Ok(#(indexes, domains))
    }
  }
}
