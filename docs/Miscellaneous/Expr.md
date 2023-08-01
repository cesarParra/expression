# Expr
## Methods
### `public accept(Visitor v)`
---
## Classes
### Binary

**Inheritance**

[Expr](/Miscellaneous/Expr.md)
 &gt; 
Binary

#### Constructors
##### `public Binary(Expr left, Token operator, Expr right)`
---
#### Fields

##### `public left` → `Expr`


##### `public operator` → `Token`


##### `public right` → `Expr`


---
#### Methods
##### `public override accept(Visitor v)`
---

### Function

**Inheritance**

[Expr](/Miscellaneous/Expr.md)
 &gt; 
Function

#### Constructors
##### `public Function(Token name, List&lt;Expr&gt; parameters)`
---
#### Fields

##### `public name` → `Token`


##### `public parameters` → `List&lt;Expr&gt;`


---
#### Methods
##### `public override accept(Visitor v)`
---

### Grouping

**Inheritance**

[Expr](/Miscellaneous/Expr.md)
 &gt; 
Grouping

#### Constructors
##### `public Grouping(Expr expression)`
---
#### Fields

##### `public expression` → `Expr`


---
#### Methods
##### `public override accept(Visitor v)`
---

### Literal

**Inheritance**

[Expr](/Miscellaneous/Expr.md)
 &gt; 
Literal

#### Constructors
##### `public Literal(Object value)`
---
#### Fields

##### `public value` → `Object`


---
#### Methods
##### `public override accept(Visitor v)`
---

### Unary

**Inheritance**

[Expr](/Miscellaneous/Expr.md)
 &gt; 
Unary

#### Constructors
##### `public Unary(Token operator, Expr right)`
---
#### Fields

##### `public operator` → `Token`


##### `public right` → `Expr`


---
#### Methods
##### `public override accept(Visitor v)`
---

---
