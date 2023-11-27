---
title: Considerations
nextjs:
  metadata:
    title: Considerations
    description: Learn about the different considerations when using Expression.
---

When using the endpoint that takes a record Id as the context or fetching data through the `FETCH` function,
the query is performed `with sharing` by default, so any records that the user does not have access to
will not be returned or taken into account in the operation.

To change this behavior, use configuration settings used by the evaluator by passing
an `expression.Configuration` object to the `run` method with a `sharing` property set to
`expression.Configuration.SharingMode.WITHOUT`.
