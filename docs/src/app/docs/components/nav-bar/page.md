---
title: Nav Bar
nextjs:
  metadata:
    title: Nav Bar
    description: Learn about the Nav Bar component.
---

The `Nav Bar` component allows you to display a navigation bar with links to other pages.

## Targets

{% badge text="Experience Builder Sites" color="indigo" /%}

## Data Structure

```
{
  logo: {
    name: string,
    url: string
  },
  menuItems: [
    {
      label: string,
      url": string
    }
  ],
  callToAction?: Button
}
```

### Example

The following expression can be used to query for Navigation Menu Items and display them in the Nav Bar component:

```
{
	"logo": {
		"name": "Example",
		"imagePath": $Resource.logo,
		"url": "/"
	},
	"menuItems": Query(NavigationMenuItem(where: Status = "Live")["Label", "Target", "Status", "Position"]) 
		-> SORT("Position")
		-> MAP({
			"label": Label,
			"url": Target
		}),
	"callToAction": {
      "label": "Contact Us",
      "type": "navigation_namedPage",
      "src": "contact_us__c"
    }
}
```

![Button](./../../assets/components/navBar/navBar.png)
