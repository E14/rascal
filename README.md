# Rascal

Rascal is a [chaos monkey](https://netflix.github.io/chaosmonkey/) for Beam processes.

Rascal is meant primarily as a development and testing aid, but the long-term aim is for it to
eventually be ready for production deployment.

## Installation

The package can be installed by adding `rascal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rascal, git: "https://github.com/e14/rascal.git", :optional, only: [:dev]}
  ]
end
```


