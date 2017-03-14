Autoloading code is a mechanism in Rails that causes frameworks, classes, and code to be loaded automatically on boot. This helps productivity by allowing developers to freely use constants and classes without having to explicitly require them.

An issue arises however that large amounts of code that are not needed for boot are loaded during the boot of an application, or are loaded out of order.

The diagram below shows how files and classes are autoloaded.


<!---
```diagram
graph TD
subgraph Autoloading
  Autoload
  Finished
end

subgraph AutoloadPath
  AutoloadPath
  NameError 
end

subgraph Loading
  Load
  LoadError
end

subgraph Parsing
  Parse
end

%% Autoloading
Entry[Start Here]-\->Autoload
Autoload-- Empty Autoload Path -\->Finished
Autoload-- Load path from autoload path -\->Load

%% AutoloadPath Paths
AutoloadPath--Cannot find a class to match Constant -\->NameError[NameError: uninitialized constant MyConstant]
AutoloadPath-- Find file that matches the Constant -\->Load[Load File]

%% Parse Paths
Parse-- Encounter Constant we don't know -\->AutoloadPath
Parse-. Finished Parsing .->Autoload

%% Load Paths
Load-- Class definition matches file -\->Parse[Parse Class]
Load-- Class definition does not match file -\->LoadError[LoadError: Expected `file` to define Class]
%% Load-. Finished Loading Class .->Autoload
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/0f5e2e3da6b82b2ac0c974d9c82e0297.png' alt='diagram image' height='250px'>


### Problem
In the code snippet below, class `A` defines a class `B`. This means that the constant `B` is now defined. In the diagram above, we see that the un-nested class `B` depends on the `ConstantMissing` error to load it during auto-load. However, since `A::B` is defined, a `ConstantMissing` hook will never happen as `B` will resolve to `A::B` - and thus `B` will never be loaded.

```ruby
class A
   class B
   end
end

class B
end
```

