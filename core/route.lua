-- kristal | 31.03.2018
-- By daelvn
-- API routes

local list = "limit=:limit&offset=:offset"

return {
  addresses    = {
    get          = "/addresses/:address",
    transactions = "/addresses/:address/transactions?" .. list,
    names        = "/addresses/:address/names",
  },
  transactions = {
    list   = "/transactions",
    latest = "/transactions/latest",
    get    = "/transactions/:id",
    make   = "/transactions"
  },
  names        = {
    get      = "/names/:name",
    register = "/names/:name",
  },
  misc         = {
    login     = "/login",
    motd      = "/motd",
    supply    = "/supply",
  }
}
