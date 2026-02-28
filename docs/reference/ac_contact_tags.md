# ActiveCampaign Contact Tags

Manage tags on contacts.

Returns a tibble with tag names resolved. The raw API only returns tag
IDs; this function automatically joins against
[`ac_tags()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_tags.md)
to include tag names.

## Usage

``` r
ac_contact_tags(contact_id)
```

## Arguments

- contact_id:

  Contact ID

## Value

A tibble with columns `contact_id`, `tag_id`, `tag_name`, and
`contact_tag_id` (the association ID, used by
[`ac_remove_tag()`](https://pcstrategyandopsco.github.io/activecampaignr/reference/ac_remove_tag.md))
