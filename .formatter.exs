locals_without_parens = [
  filter: 2,
  field: 1,
  field: 2,
  orderable: 1,
  limitable: 1,
  paginateable: 1
]

[
  inputs: [
    "mix.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  locals_without_parens: locals_without_parens,
  import_deps: [:ecto],
  export: [
    locals_without_parens: locals_without_parens
  ]
]
