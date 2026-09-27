// Records what the PWA's TypeScript engine answers for a grid of scenarios,
// so the Dart port can be checked against it (test/domain/engine_golden_test.dart).
//
// The TypeScript engine is gone from this repository; the fixture it produced,
// test/fixtures/engine_golden.json, is a frozen record of its behaviour. To
// regenerate it, check out the last PWA commit and run, from that checkout:
//
//   tool/engine_golden/generate.sh <pwa-checkout>
//
// Scenarios are chosen so the answers don't depend on the machine's time zone:
// instants are UTC, and fixed-time medications (which work on the wall clock)
// take and give local wall-clock times. generate.sh runs this under several
// zones and refuses output that differs between them.

import { pathToFileURL } from 'node:url'
import { join, resolve } from 'node:path'

const src = resolve(process.argv[2] ?? '')
const { computeMedicationStatus } = await import(pathToFileURL(join(src, 'engine/contract.ts')).href)
const { computeMedicationInventoryStatus } = await import(pathToFileURL(join(src, 'engine/inventory.ts')).href)

type Json = Record<string, unknown>

const MINUTE = 60_000
const pad = (n: number, width = 2) => String(n).padStart(width, '0')

// Local wall-clock time, without an offset: "2026-06-10T08:00:00.000".
function wallClock(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
    `T${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}` +
    `.${pad(date.getMilliseconds(), 3)}`
}

function at(base: string, minutes: number): string {
  return new Date(Date.parse(base) + minutes * MINUTE).toISOString()
}

// --- Medications ------------------------------------------------------------

const medications: Record<string, Json> = {}

function med(id: string, schedule: Json, extra: Json = {}): string {
  medications[id] = {
    id,
    patientId: 'patient-1',
    name: id,
    active: true,
    defaultDoseText: '1 tablet',
    schedule,
    ...extra,
  }
  return id
}

const reminderVariants: Record<string, Json | undefined> = {
  unset: undefined,
  off: { enabled: false, earlyReminderMinutes: 15 },
  on: { enabled: true },
  early10: { enabled: true, earlyReminderMinutes: 10 },
  early15: { enabled: true, earlyReminderMinutes: 15 },
}

const intervalMeds: string[] = []
for (const minutes of [60, 120, 285, 480]) {
  const variants = minutes === 120 ? Object.keys(reminderVariants) : ['unset', 'early15']
  for (const variant of variants) {
    intervalMeds.push(med(`interval-${minutes}-${variant}`, { type: 'interval', intervalMinutes: minutes }, {
      reminderSettings: reminderVariants[variant],
    }))
  }
}

const prnMeds: string[] = []
for (const minutes of [60, 240]) {
  for (const variant of ['unset', 'early10']) {
    prnMeds.push(med(`prn-${minutes}-${variant}`, { type: 'prn', minimumIntervalMinutes: minutes }, {
      reminderSettings: reminderVariants[variant],
    }))
  }
}

const fixedMeds = [
  med('fixed-three', { type: 'fixed_times', timesOfDay: ['08:00', '12:00', '20:00'] }, {
    reminderSettings: reminderVariants.early15,
  }),
  med('fixed-one', { type: 'fixed_times', timesOfDay: ['21:30'] }),
  med('fixed-unsorted', { type: 'fixed_times', timesOfDay: ['20:00', '08:00'] }, {
    reminderSettings: reminderVariants.early10,
  }),
  med('fixed-edges', { type: 'fixed_times', timesOfDay: ['00:00', '23:59'] }),
  med('fixed-empty', { type: 'fixed_times', timesOfDay: [] }),
]

const taperMeds = [
  med('taper-two-step', {
    type: 'taper',
    rules: [
      { startDate: '2026-06-01', endDate: '2026-06-05', intervalMinutes: 480 },
      { startDate: '2026-06-05', intervalMinutes: 720 },
    ],
  }, { reminderSettings: reminderVariants.early15 }),
  med('taper-unsorted', {
    type: 'taper',
    rules: [
      { startDate: '2026-06-12', intervalMinutes: 1440 },
      { startDate: '2026-06-01', endDate: '2026-06-08', intervalMinutes: 360 },
      { startDate: '2026-06-08', endDate: '2026-06-12', intervalMinutes: 720 },
    ],
  }),
  med('taper-gap', {
    type: 'taper',
    rules: [
      { startDate: '2026-06-01', endDate: '2026-06-04', intervalMinutes: 240 },
      { startDate: '2026-06-06', intervalMinutes: 480 },
    ],
  }),
  med('taper-future', {
    type: 'taper',
    rules: [{ startDate: '2026-06-20', intervalMinutes: 480 }],
  }),
  med('taper-same-start', {
    type: 'taper',
    rules: [
      { startDate: '2026-06-01', intervalMinutes: 240 },
      { startDate: '2026-06-01', intervalMinutes: 480 },
    ],
  }),
  med('taper-ended', {
    type: 'taper',
    rules: [{ startDate: '2026-06-01', endDate: '2026-06-03', intervalMinutes: 360 }],
  }),
  med('taper-empty', { type: 'taper', rules: [] }),
]

const inventoryMeds = [
  med('inventory-off', { type: 'interval', intervalMinutes: 240 }, {
    inventoryEnabled: false, initialQuantity: 30, doseAmount: 1,
  }),
  med('inventory-unset', { type: 'interval', intervalMinutes: 240 }),
  med('inventory-unconfigured', { type: 'interval', intervalMinutes: 240 }, {
    inventoryEnabled: true, initialQuantity: 30,
  }),
  med('inventory-zero-dose', { type: 'interval', intervalMinutes: 240 }, {
    inventoryEnabled: true, initialQuantity: 30, doseAmount: 0, lowSupplyThreshold: 5,
  }),
  med('inventory-plain', { type: 'interval', intervalMinutes: 240 }, {
    inventoryEnabled: true, initialQuantity: 30, doseAmount: 1,
  }),
  med('inventory-threshold', { type: 'interval', intervalMinutes: 240 }, {
    inventoryEnabled: true, initialQuantity: 4, doseAmount: 1, lowSupplyThreshold: 2,
  }),
  med('inventory-fractional', { type: 'interval', intervalMinutes: 240 }, {
    inventoryEnabled: true, initialQuantity: 2.5, doseAmount: 0.5, lowSupplyThreshold: 1,
  }),
  med('inventory-empty', { type: 'interval', intervalMinutes: 240 }, {
    inventoryEnabled: true, initialQuantity: 0, doseAmount: 1,
  }),
]

// --- Dose histories ---------------------------------------------------------
// Written against a placeholder medication id; each case fills in its own.

const T0 = '2026-06-10T06:00:00.000Z'

function dose(id: string, timestampGiven: string, supersedes?: string, medicationId = '$med'): Json {
  return supersedes
    ? { id, medicationId, timestampGiven, corrected: true, supersedesDoseEventId: supersedes }
    : { id, medicationId, timestampGiven, corrected: false }
}

const histories: Record<string, Json[]> = {
  none: [],
  single: [dose('d1', T0)],
  two: [dose('d1', at(T0, -240)), dose('d2', T0)],
  outOfOrder: [dose('d2', T0), dose('d1', at(T0, -240))],
  correctedEarlier: [dose('orig', T0), dose('fix', at(T0, -30), 'orig')],
  correctedLater: [dose('orig', at(T0, -120)), dose('fix', at(T0, 10), 'orig')],
  correctionChain: [dose('orig', T0), dose('fix1', at(T0, -20), 'orig'), dose('fix2', at(T0, -45), 'fix1')],
  tie: [dose('dose-a', T0), dose('dose-b', T0)],
  otherMedication: [dose('x1', T0, undefined, 'someone-else')],
  seconds: [dose('d1', '2026-06-10T06:00:30.250Z')],
}

// For tapers: doses placed relative to the rule dates instead.
const taperHistories: Record<string, Json[]> = {
  none: [],
  beforeRules: [dose('d1', '2026-05-30T12:00:00.000Z')],
  early: [dose('d1', '2026-06-02T09:00:00.000Z')],
  recent: [dose('d1', '2026-06-10T03:30:00.000Z')],
}

const inventoryHistories: Record<string, Json[]> = {
  none: [],
  single: histories.single,
  two: histories.two,
  correctedEarlier: histories.correctedEarlier,
  correctionChain: histories.correctionChain,
  four: [dose('d1', at(T0, -720)), dose('d2', at(T0, -480)), dose('d3', at(T0, -240)), dose('d4', T0)],
  five: [
    dose('d1', at(T0, -960)), dose('d2', at(T0, -720)), dose('d3', at(T0, -480)),
    dose('d4', at(T0, -240)), dose('d5', T0),
  ],
}

// --- Cases ------------------------------------------------------------------

// Boundaries of the intervals above: due, due soon (20 min), missed (1.5x).
const instantNows = [-30, 0, 59, 60, 61, 100, 119.5, 120, 121, 180, 284, 285, 286, 479, 480, 481,
  721, 2880].map((m) => at(T0, m))

const wallClockNows = [
  '2026-06-10T05:00:00.000', '2026-06-10T07:44:59.000', '2026-06-10T07:45:00.000',
  '2026-06-10T07:59:59.999', '2026-06-10T08:00:00.000', '2026-06-10T08:00:30.000',
  '2026-06-10T08:21:00.000', '2026-06-10T11:50:00.000', '2026-06-10T13:15:00.000',
  '2026-06-10T19:59:00.000', '2026-06-10T20:00:00.000', '2026-06-10T21:29:00.000',
  '2026-06-10T21:30:00.000', '2026-06-10T23:00:00.000', '2026-06-10T23:59:30.000',
  '2026-06-11T00:00:00.000', '2026-06-11T00:00:01.000',
]

const taperNows = [
  '2026-05-31T12:00:00.000Z', '2026-06-01T00:00:00.000Z', '2026-06-01T05:00:00.000Z',
  '2026-06-02T13:00:00.000Z', '2026-06-02T17:00:00.000Z', '2026-06-03T00:00:00.000Z',
  '2026-06-04T23:59:00.000Z', '2026-06-05T00:00:00.000Z', '2026-06-05T11:00:00.000Z',
  '2026-06-07T12:00:00.000Z', '2026-06-08T00:00:00.000Z', '2026-06-10T10:00:00.000Z',
  '2026-06-10T15:30:00.000Z', '2026-06-12T00:00:00.000Z', '2026-06-20T04:00:00.000Z',
  '2026-06-25T00:00:00.000Z',
]

function withMedication(events: Json[], medicationId: string): Json[] {
  return events.map((e) => (e.medicationId === '$med' ? { ...e, medicationId } : e))
}

function drop(obj: Json): Json {
  return Object.fromEntries(Object.entries(obj).filter(([, v]) => v !== undefined && v !== null))
}

const cases: Json[] = []

function statusCase(medId: string, historyName: string, events: Json[], now: string, local: boolean) {
  const medication = medications[medId]
  const doseEvents = withMedication(events, medId)
  const status = computeMedicationStatus({ medication, doseEvents, now: new Date(now) })
  // Fixed-time answers are wall-clock times, so they're recorded as such.
  const time = (iso?: string) => (iso === undefined ? undefined : local ? wallClock(new Date(iso)) : iso)
  cases.push({
    kind: 'status',
    medication: medId,
    history: historyName,
    now,
    expect: drop({
      label: status.statusLabel,
      eligibleNow: status.eligibleNow,
      lastGivenAt: status.lastGivenAt,
      nextEligibleAt: time(status.nextEligibleAt),
      reminderAt: time(status.reminderAt),
      minutesUntilEligible: status.minutesUntilEligible,
      tooEarlyByMinutes: status.tooEarlyByMinutes,
      overdueByMinutes: status.overdueByMinutes,
    }),
  })
}

// Every history against one interval; a representative few against the rest.
const fewHistories = ['none', 'single', 'correctedEarlier', 'tie', 'seconds']
for (const medId of [...intervalMeds, ...prnMeds]) {
  const names = medId === 'interval-120-unset' ? Object.keys(histories) : fewHistories
  for (const name of names) {
    for (const now of instantNows) statusCase(medId, name, histories[name], now, false)
  }
}

for (const medId of fixedMeds) {
  for (const name of ['none', 'single']) {
    for (const now of wallClockNows) statusCase(medId, name, histories[name], now, true)
  }
}

for (const medId of taperMeds) {
  for (const [name, events] of Object.entries(taperHistories)) {
    for (const now of taperNows) statusCase(medId, `taper:${name}`, events, now, false)
  }
}

for (const medId of inventoryMeds) {
  for (const [name, events] of Object.entries(inventoryHistories)) {
    const inventory = computeMedicationInventoryStatus({
      medication: medications[medId],
      doseEvents: withMedication(events, medId),
    })
    cases.push({
      kind: 'inventory',
      medication: medId,
      history: `inventory:${name}`,
      expect: drop({ ...inventory }),
    })
  }
}

const allHistories: Record<string, Json[]> = { ...histories }
for (const [name, events] of Object.entries(taperHistories)) allHistories[`taper:${name}`] = events
for (const [name, events] of Object.entries(inventoryHistories)) allHistories[`inventory:${name}`] = events

// One case per line keeps the file small and its diffs readable.
process.stdout.write([
  '{',
  ' "about": "Answers from the PWA TypeScript engine. Generated by tool/engine_golden/generate.mts; do not edit.",',
  ` "medications": ${JSON.stringify(medications, null, 1).replace(/\n/g, '\n ')},`,
  ` "histories": ${JSON.stringify(allHistories)},`,
  ' "cases": [',
  cases.map((c) => '  ' + JSON.stringify(c)).join(',\n'),
  ' ]',
  '}',
].join('\n') + '\n')
