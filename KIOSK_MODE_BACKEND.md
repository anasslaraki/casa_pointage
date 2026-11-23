# Casa Pointage — "Kiosk" role: face screen only

For the backend developer. It describes a new behaviour of the mobile app and what the API must change or confirm so
the app can do it. The app side is small; most of the work is on the API (sections 5 and 6).

---

## 1. The feature in one paragraph

After the login, the app looks at the user's **role**.

- **`SuperviseurDepot`** (today's supervisor): nothing changes. Tabs Équipe, Enrôlement, Historique, Profil, manual
  pointage, absences, anomalies, as now.
- **Any other role we define later** (called **kiosk role** below): the app shows **only the face recognition screen**.
  No tabs, no team list, no menu. The person looks at the camera; when the face is recognised, the app sends the
  pointage to the API at once, shows the result for a few seconds ("Arrivée pointée" or "Sortie pointée", the name, the
  time), then goes back to the camera for the next person. Nothing else is possible in the app, except logging out.

Typical use: a phone or tablet fixed at the depot entrance, logged in with a kiosk account, where everyone points
themselves.

---

## 2. What the user sees (kiosk role)

```
Login ──► Face screen ──► face recognised ──► Result (3 s) ──► Face screen …
              │                                   │
              │ no face / not recognised          └─ error message from the API
              └─ "Réessayez" (stays on the screen; no manual pointage)
```

1. Login (same screen as today).
2. Face screen: camera, oval, head-turn check (turn the head to one side, then the other, then look straight).
3. Face recognised on the phone → **`POST /pointages` is sent automatically**. There is **no confirmation card** and
   no "Modifier" for the assignment: the API must use the defaults (section 5.4).
4. Result: person's name, "Arrivée pointée" / "Sortie pointée" (from the API field `type`), time, lateness if any.
   The text comes from the API answer. After about 3 seconds the camera restarts by itself.
5. A small "Se déconnecter" in a corner (a kiosk account can log out; nothing else).

Not available to the kiosk role: manual pointage, enrolment, team list, history, person sheet, absence, anomaly,
assignment change, lateness reason.

---

## 3. What is sent to the API

The face recognition stays **on the phone** (no photo or video of the face is sent). Only the result is sent, with the
same call as today:

```
POST /pointages
{
  "agentId": 23,                      // the person that was recognised (never left out in kiosk mode)
  "methode": "Visage",
  "scoreVisage": 0.87,                // similarity, 0 to 1
  "latitude": 33.5912,
  "longitude": -7.6201,
  "precisionMetres": 8
}
```

`circuitId`, `vehiculeId`, `chariotId` and `motifRetard` are **not sent** in kiosk mode (the API uses the defaults).
The call carries the usual headers: the API key (`?code=…`) and `Authorization: Bearer <access token>` of the kiosk
account.

The answer is the one of today (`200` → `data.pointage`, `data.type`, `data.enRetard`, `data.retardMinutes`,
`data.auDepot`). The app displays `message` / `data.type` as they come.

If the backend wants **more data** with each kiosk pointage (for example a photo as proof, a device id, the kiosk
account id), tell us now: see question Q3.

---

## 4. How the phone finds who the person is

The phone compares the face with the face templates it has downloaded, then sends the winning `agentId`. So the
kiosk phone needs the templates of **everyone who may point there**.

Today: `GET /gabarits?modeleVersion=sface-2021dec` returns the templates of the **supervisor's team**.
For a kiosk account the API must return **all enrolled agents of the kiosk's depot(s)** (the `depots` of its login
answer). See section 5.2.

Recognition rule (unchanged): best score ≥ 0.70 **and** at least 0.05 ahead of the second best. Below that the app
does **not** call the API; it shows "Visage non reconnu, réessayez" and restarts the camera.

---

## 5. What the backend must change or confirm

### 5.1 The role and the login

- Choose the **role name(s)** of the kiosk accounts (example: `Pointeur`, `Kiosque`; **to be defined**). The app reads
  `role` from `POST /Authentication` and from `GET /profil`. Please keep that field reliable.
- Today the login can answer `400 "Ce compte n'est pas un compte superviseur."` and `GET /profil` answers `403` for a
  non-supervisor. These checks must **let the kiosk role through**.
- `400 "Aucun dépôt n'est rattaché à ce superviseur."` must also apply to kiosk accounts (a kiosk needs a depot),
  with a message that is not specific to supervisors.
- Login answer for a kiosk account: same shape as today. `agent` may be `null` (a kiosk account is not a person).
  `depots` must be filled.

### 5.2 Templates for the kiosk

`GET /gabarits?modeleVersion=…` for a kiosk token must return the templates of **all enrolled agents of its
depot(s)**, paginated as today (`page`, `pageSize`, `totalPages`, `items`).
Each item stays: `agentId`, `matricule`, `fullName`, `gabarit`, `modeleVersion`, `dateEnrolement`.

> Size: if a depot has 300 agents, the phone downloads 300 templates (about 700 bytes each in base64) at login. That
> is fine. For a much larger depot, tell us.

### 5.3 Who may point whom (permissions)

For a kiosk token, `POST /pointages` must accept an `agentId` **belonging to the kiosk's depot(s)** and refuse any
other with a clear `400` message. The role must be enforced **on the server**: hiding screens in the app is not
security. A kiosk token should be allowed **only**:

| Call | Why |
|---|---|
| `POST /Authentication`, `POST /RefreshToken` | login |
| `GET /profil` | role and depot |
| `GET /gabarits` | the templates |
| `POST /pointages` (face only) | the pointage |

Everything else (`/equipe`, `/enrolements`, `/absences`, `/declarations`, manual pointage, `/historique`, `/journee`)
should answer `403` for a kiosk token.

### 5.4 Defaults when no assignment is sent

The kiosk does not send `circuitId`, `vehiculeId`, `chariotId` or `motifRetard`. The API must use the person's normal
assignment of the day (as it proposes today) and accept a `null` lateness reason. If a lateness reason is mandatory
in some case, tell us: the kiosk has no screen for it.

### 5.5 Pointage rules (please confirm they still apply)

- Arrival or departure is decided by the API (nothing yet → arrival; arrival without departure → departure).
- The `400` messages we already show stay valid: "Cette personne vient d'être pointée." (a person who stands in
  front of the camera twice in a row), "Arrivée et sortie déjà pointées pour cette journée…", "Position GPS
  obligatoire.".
- **Double pointage**: a kiosk invites repeated attempts. The current guard "Cette personne vient d'être pointée."
  must keep working for a few minutes (please say how long: Q4).

### 5.6 Enrolment

Kiosk users **cannot enrol**. A person must be enrolled first by a supervisor (as today). Someone who is not enrolled
is simply "not recognised" at the kiosk.

---

## 6. Questions for the backend developer

| # | Question | Our proposal |
|---|---|---|
| Q1 | Name(s) of the kiosk role(s)? | one role, e.g. `Pointeur` |
| Q2 | Is the kiosk account tied to one depot or several? | one or several, from `depots` |
| Q3 | Do you need extra data per pointage (photo as proof, device id)? | no photo (privacy); optional `appareilId` if useful |
| Q4 | How long does "Cette personne vient d'être pointée." block a second pointage? | 2 minutes |
| Q5 | Must the kiosk work **offline**? | no: the app today sends online only; if yes, we add a queue with `dateAction` and `horsConnexion` as in the spec |
| Q6 | Should the `agent` of the login answer be `null` for a kiosk? | yes |
| Q7 | Is the GPS check (`auDepot`) the same for a kiosk? | yes: the position of the phone is sent |

---

## 7. App side (for information)

- Read `role` after the login and at start-up from the stored session.
- `SuperviseurDepot` → current navigation. Kiosk role → a single screen: the face scan, in "identification" mode
  against the downloaded templates, with automatic sending, result card and restart.
- Unknown role → we show the supervisor interface only if `role == SuperviseurDepot`; any other role goes to the kiosk.
  If you prefer an explicit list of kiosk roles, tell us.
- Templates are stored encrypted on the phone and deleted at logout (as today).

---

## 8. Test checklist (once the API is ready)

1. Login with a supervisor: everything as before.
2. Login with a kiosk account: only the camera is shown; no tabs.
3. Enrolled agent of the depot looks at the camera: `POST /pointages` is sent, "Arrivée pointée" is shown, the camera
   restarts after about 3 seconds.
4. Same agent again a minute later: the API message "Cette personne vient d'être pointée." is shown.
5. Same agent at the end of the day: "Sortie pointée".
6. A person not enrolled, or a photo of a face: "Visage non reconnu"; **no** call to `/pointages`.
7. Kiosk token on `GET /equipe`, `POST /absences`, `POST /enrolements`, manual `POST /pointages`: `403`.
8. Kiosk token with an `agentId` of another depot: `400` with a clear message.
9. Kiosk account without a depot: login refused with a clear message.
