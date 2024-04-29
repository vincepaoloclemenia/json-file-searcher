# README

## Getting Started

1. Install version 3.1.4 and bundler

2. Then run the following command:
```
bundle install
```

## Usage

You may simply copy paste the following command

```
JsonSearcherService.new(query: { full_name: 'jane' }).call
```

This command will return all the hashes with full_name that matches the term _jane_

## Attributes to specify

### path: String

You may specify a full path of the file (works only with console). The default is the json file save in the codebase _('public/clients.json')_.

```
JsonSearcherService.new(query: { full_name: 'jane' }, path: 'full/path/of/jsonfile).call
```

### find_duplicates: Boolean

Finding duplicates can be optional. It will find and return all of the hashes with the same emails. Default of value for this parameter is false.

```
JsonSearcherService.new(query: { full_name: 'jane' }, find_duplicates: false).call
```

