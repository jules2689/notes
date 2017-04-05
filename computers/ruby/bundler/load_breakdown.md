## Load Breakdown


<!---
```diagram
graph TD
  load.setup
  load.setup-\->load_method[load]
  load.setup--663ms-\->setup

  subgraph lib/bundler/runtime.rb
    requested_specs
  end
  setup--630ms-\->requested_specs

  subgraph lib/bundler/definition.rb
    requested_specs--368ms-\->specs_for
    specs_for--248ms-\->specs1[specs]
    specs_for--121ms-\->spec.for
  end

  subgraph lib/bundler/spec_set.rb
    specs1--168ms-\->materialize
    spec.for--106ms-\->spec.dependencies

  end

  subgraph stub_specification.rb
    spec.dependencies--104ms-\->dependencies
  end

  subgraph lib/bundler/lazy_specification.rb
    materialize--157ms-\->__materialize__
    __materialize__--137ms-\->specs2[specs]
    __materialize__--12ms-\->search
    specs2--34ms-\->RubyGemsSpecs[RubyGems Specs]
    specs2--91ms-\->GitSpecs[Git Specs]
  end

  subgraph RUBY/rubygems/specifications.rb
    RubyGemsSpecs-\->load
    load-\->eval[eval code, binding, file]
    dependencies--104ms-\->gem_dependencies[dependencies]
  end

  subgraph lib/bundler/source/path.rb
    GitSpecs--90ms-\->load_spec_files
    load_spec_files--18ms-\->glob[Dir.glob]
  end

  subgraph lib/bundler.rb
    load_spec_files--69ms-\->load_gemspec
    load_gemspec--67ms-\->load_gemspec_uncached
    load_gemspec_uncached--55ms-\->eval_gemspec
  end
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/644eeff0ba582535065a98cf941ae6bc.png' alt='diagram image' width='100%'>
