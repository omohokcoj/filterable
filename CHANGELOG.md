# Changelog

### 0.7.0

- Fix params `to_atoms_map` can cause a memory leak (#11)
- Fix `cast: :atom` can cause a memory leak (#8)

  `cast: :atom` is now deprecated in favor of `cast: {:atom, [:foo, :bar]}`.
  If the old behaviour is required, `cast: :atom_unchecked` can be used.
