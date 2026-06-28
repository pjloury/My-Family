# Injecting Mock Data for App Store Screenshots

## How it works

`MockDataLoader.swift` (wrapped in `#if DEBUG`) checks for either:
- Launch argument: `--inject-mock-data`
- Environment variable: `INJECT_MOCK_DATA=1`

When present, it overwrites UserDefaults with a curated family + friends dataset before the app initialises, so the first screen you see is already populated.

## Mock data summary

**"My Family" list (10 contacts)**
| Name | Relation | Birthday | Notes |
|------|----------|----------|-------|
| Patricia Loury (Mom) | Mother | June 27 | Birthday TODAY |
| Richard Loury (Dad) | Father | June 30 | Birthday in 3 days |
| Emma Loury | Sister | July 11 | Birthday in 2 weeks |
| Sophia Loury (Sofi) | Wife | Aug 14 | Has Wedding Anniversary special date |
| Jake Loury | Son | Sep 5 | Age 8 |
| Lily Loury | Daughter | Mar 20 | Has First Day of School special date |
| Rose Gallagher (Grandma Rose) | Grandmother | Oct 15 | Deceased 2019 |
| Arthur Gallagher (Grandpa Art) | Grandfather | Dec 3 | Deceased 2008 |
| Michael Loury (Uncle Mike) | Uncle | Nov 19 | |
| Claire Nguyen | Sister-in-Law | Feb 8 | |

**"Close Friends" list (4 contacts)**
| Name | Birthday | Notes |
|------|----------|-------|
| Sarah Kim | July 4 | Has Friendiversary special date |
| Marcus Johnson | Apr 22 | |
| Priya Patel | Jan 15 | |
| Tom Reyes | Aug 30 | |

## Setup in Xcode (one-time)

1. Open the **Fam List** scheme: Product → Scheme → Edit Scheme (⌘<)
2. Select **Run** → **Arguments** tab
3. Under "Arguments Passed On Launch", add: `--inject-mock-data`
4. Click **Close**

Now every simulator launch will load mock data. Remove the argument when you're done.

## Resetting mock data

The mock data overwrites UserDefaults on every launch while the argument is present. To go back to real data, remove `--inject-mock-data` from the scheme and delete + reinstall the app on the simulator (or reset the simulator content).

## Useful simulator screen sizes for App Store

- iPhone 6.9": iPhone 16 Pro Max
- iPhone 6.5": iPhone 11 Pro Max / XS Max  
- iPad 13": iPad Pro 13-inch (M4)
- iPad 12.9": iPad Pro 12.9-inch (6th gen)
