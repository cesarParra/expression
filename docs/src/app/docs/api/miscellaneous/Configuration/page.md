---
nextjs:
  metadata:
    title: Configuration
    description: Api documentation for the Configuration class}
---

# Configuration Class

Configuration class for the evaluator.

## Namespace
expression

## Fields
### `globalContextVariablePrefix`

#### Signature
```apex
global globalContextVariablePrefix
```

#### Type
String

---

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
**[Configuration](Configuration)**

---

### `printAst()`

#### Signature
```apex
global Configuration printAst()
```

#### Return Type
**[Configuration](Configuration)**

---

### `withDiagnostics()`

#### Signature
```apex
global Configuration withDiagnostics()
```

#### Return Type
**[Configuration](Configuration)**

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
**[Configuration](Configuration)**

---

### `withGlobalContextVariablePrefix(prefix)`

#### Signature
```apex
global Configuration withGlobalContextVariablePrefix(String prefix)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| prefix | String |  |

#### Return Type
**[Configuration](Configuration)**

## Enums
### SharingMode Enum

#### Values
| Value | Description |
|-------|-------------|
| WITH |  |
| WITHOUT |  |