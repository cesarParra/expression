# Configuration Class

Configuration class for the evaluator.

## Namespace
expression

## Fields
### `sharing`

#### Signature
```apex
global sharing
```

#### Type
SharingMode

---

### `printAst`

#### Signature
```apex
global printAst
```

#### Type
Boolean

---

### `customContext`

#### Signature
```apex
global customContext
```

#### Type
Map&lt;String,Object&gt;

## Methods
### `respectSharing(respect)`

#### Signature
```apex
global Configuration respectSharing(Boolean respect)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| respect | Boolean |  |

#### Return Type
**[Configuration](/docs/api/miscellaneous/Configuration)**

---

### `printAst()`

#### Signature
```apex
global Configuration printAst()
```

#### Return Type
**[Configuration](/docs/api/miscellaneous/Configuration)**

---

### `withDiagnostics()`

#### Signature
```apex
global Configuration withDiagnostics()
```

#### Return Type
**[Configuration](/docs/api/miscellaneous/Configuration)**

---

### `withCustomContext(objectsByStrings)`

#### Signature
```apex
global Configuration withCustomContext(Map<String,Object> objectsByStrings)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| objectsByStrings | Map&lt;String,Object&gt; |  |

#### Return Type
**[Configuration](/docs/api/miscellaneous/Configuration)**

## Enums
### SharingMode Enum

#### Values
| Value | Description |
|-------|-------------|
| WITH |  |
| WITHOUT |  |