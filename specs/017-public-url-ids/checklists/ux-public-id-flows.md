# UX Review: Public ID Flows

Checklist to verify all user-facing links and flows use public IDs correctly.

## Team Pages

- [x] Team show page URL uses `tm_<segment>` format
- [x] Team index page links to teams via public_id URLs
- [x] Team edit/update forms route via public_id
- [x] Team member list (memberships) uses team public_id in URLs
- [x] Invitation accept/refuse links use team public_id
- [x] Leave team action routes via team public_id

## Game Pages

- [x] Game show page URL uses `gm_<segment>` format
- [x] Game links from team show page use public_id URLs
- [x] Active game links on team page display "Partie en cours" (no numeric ID)
- [x] Game title displays "Partie - 'Team'" (no numeric ID)

## Nested Flows

- [x] New proposal form routes via game public_id
- [x] Proposal submission and redirect uses game public_id
- [x] Guessing form routes via game public_id
- [x] Guess submission and redirect uses game public_id
- [x] Results page routes via game public_id
- [x] Results page header shows no numeric ID

## Error Handling

- [x] Numeric ID in game URL returns 404 with generic message
- [x] Numeric ID in team URL returns 404 with generic message
- [x] Malformed public_id returns 404 (no information leak)
- [x] Wrong prefix (e.g. `tm_` for a game) returns 404

## Shareability

- [x] Shared game links work for authorized team members
- [x] Shared team links work for team members
- [x] URL copying gives clean public_id URLs (no numeric IDs visible)
