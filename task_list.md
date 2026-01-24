# Task List: Required Changes

This document compares the requirements in REQUIREMENTS.md to the current application behaviour and lists the necessary changes.

---

## Summary

The application has core infrastructure (database, state management, QR export, match/team selection) but is missing several key features for auto and teleop data collection.

---

## 1. Auto (Aura) Tab - Missing Features

**Current state:** Only has climb tracking (level and position).

**Required additions:**

- [ ] **Add starting position tracking** - Track where the robot started on the field
- [ ] **Add "robot moved" tracking** - Boolean to track whether the robot moved during auto
- [ ] **Add volley scoring component** - Track volleys scored during auto period (see Volley Component below)

---

## 2. Teleop Tab - Needs Full Implementation

**Current state:** The `tele.dart` file is essentially empty/stub.

**Required additions:**

- [ ] **Implement volley scoring component** - Track volleys scored during teleop period
- [ ] **Implement climb tracking** - Track robot climbing during teleop (level + position)
- [ ] **Remove THE END tab** - The endgame climbing data should be tracked in the Teleop tab]

---

## 3. New Reusable Component: Volley Scoring Widget

**Current state:** Does not exist.

**Required implementation:**

- [ ] **Create VolleyCard widget** containing:
  - Hopper fullness selector (0%, 25%, 50%, 75%, 100%)
  - Shot success percentage selector (0%, 25%, 50%, 75%, 100%)
  - Drag handle for reordering

- [ ] **Create VolleyList widget** containing:
  - List of VolleyCard widgets
  - "Add volley" button to append new volleys
  - Drag-to-reorder functionality
  - Swipe left/right to delete functionality

---

## 4. Database Schema Updates

**Current state:** Schema tracks basic match data but lacks fields for new features.

**Required additions:**

- [ ] **Add `start_position` field** - Store robot's starting position on field
- [ ] **Add `auto_moved` field** - Boolean for whether robot moved in auto
- [ ] **Add `auto_volleys` field** - Store auto period volleys (likely JSON array)
- [ ] **Add `teleop_volleys` field** - Store teleop period volleys (likely JSON array)
- [ ] **Separate auto vs teleop climb data** - Currently only one set of climb fields exists; may need `auto_climb_level`, `auto_climb_position`, `teleop_climb_level`, `teleop_climb_position`

---

## 5. QR Code Export Updates

**Current state:** Exports existing fields.

**Required additions:**

- [ ] **Include new fields in QR export** - Update QR generation to include starting position, auto_moved, volleys data, and separated climb data

---

## 6. Provider/State Management Updates

- [ ] **Add getters/setters for new fields** - starting position, auto_moved, volleys arrays
- [ ] **Add methods for volley manipulation** - add, remove, reorder volleys

---

## 7. Updates for climbing widget

- [ ] **UI element updates** - Don't use a 3x3 + 1 grid of radio buttons, use two sliders instead. One, climb level, goes 
from 0 to 3, with 0 representing "no climb". The other, climb position, has values for left, center, right.

## Priority Order (Suggested)

1. Database schema updates (foundation for everything else)
2. Climbing widget updates (reusable component needed by both tabs)
3. Volley scoring widget (reusable component needed by both tabs)
4. Auto (Aura) tab additions
5. Teleop tab implementation
6. QR code export updates
7. Testing and validation
