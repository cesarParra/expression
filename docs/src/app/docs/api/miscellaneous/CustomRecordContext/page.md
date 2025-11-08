---
nextjs:
  metadata:
    title: CustomRecordContext
    description: Api documentation for the CustomRecordContext class}
---

# CustomRecordContext Class

## Namespace
expression

## Fields
### `key`

#### Signature
```apex
global final key
```

#### Type
String

---

### `recordId`

#### Signature
```apex
global final recordId
```

#### Type
Id

---

### `prequeriedRecord`

#### Signature
```apex
global final prequeriedRecord
```

#### Type
SObject

## Constructors
### `CustomRecordContext(key, recordId)`

#### Signature
```apex
global CustomRecordContext(String key, Id recordId)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| key | String |  |
| recordId | Id |  |

---

### `CustomRecordContext(key, recordId, prequeriedRecord)`

#### Signature
```apex
global CustomRecordContext(String key, Id recordId, SObject prequeriedRecord)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| key | String |  |
| recordId | Id |  |
| prequeriedRecord | SObject |  |