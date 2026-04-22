builders: {
  builder = builders.mkVintageStoryV1;
  versions = [
    {
      version = "1.18.8";
      hash = "sha256-cBP+nqaIq7dIcKyyIuw/w0q5/lhcClOZ9N/O1Kuu2qk=";
    }
    {
      version = "1.18.9";
      hash = "sha256-w+BD7vi8xsGO9db2wzgHdBiSZsW8CpimC/8TugNOjhE=";
    }
    {
      version = "1.18.10";
      hash = "sha256-HR5eoNkY6BVYNtIDyDKSoWwSde9MpObw+IdKXGZhj70=";
    }
    {
      version = "1.18.11";
      hash = "sha256-hEz5dC4ftFS0QYpcuChxkXYX2Bjr6mwJ3qcnBQNmaFY=";
    }
    {
      version = "1.18.12";
      hash = "0lrvzshqmx916xh32c6y30idqpmfi6my6w26l3h32y7lkx26whc6";
    }
    {
      version = "1.18.13";
      hash = "1drrv3d5fg90a9i5zzzib0bagk79ps5l5rbjqxwbz9i3898iacj1";
    }
    {
      version = "1.18.14";
      hash = "04kr1jfdw95jf4j9cgk699z951yqwdx6nz2pvci7734cw7n37shp";
    }
    {
      version = "1.18.15";
      hash = "0syy29683hvf3wvz44gaq2lib3q07zmhdxkwxhdpxvw7cjnaf1l2";
    }
    # Versions past this used to have a different derivation in nixpkgs.
    # Hopefully, no one needs such old versions, I don't see why bother packaging them.
    # https://github.com/NixOS/nixpkgs/commit/a50269d1419600892dfe84c87b517748f938500b
  ];
}
