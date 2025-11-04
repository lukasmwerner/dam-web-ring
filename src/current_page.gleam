import gleam/dict
import gleam/http/request.{type Request}
import gleam/list
import mist.{type Connection}

pub fn index(req: Request(Connection), domains: dict.Dict(String, Int)) -> Int {
  let assert Ok(query) = request.get_query(req)
  case query |> list.key_find("referer") {
    Error(_) -> 0
    Ok(domain) -> {
      case domains |> dict.get(domain) {
        Error(_) -> 0
        Ok(index) -> index
      }
    }
  }
}
