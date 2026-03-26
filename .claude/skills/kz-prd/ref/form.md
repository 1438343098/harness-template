---
name: form
description: Used when a PRD involves form controls. Defines the specific requirement details to collect from the user for each type of form control (text input, number input, select, checkbox, radio, slider, date picker, file upload, etc.)
---

# Form Control Requirements Collection Guide

## Overview

When encountering form-related controls, ask the user the following questions for each corresponding control type to fill in the details. Each field should be confirmed through direct questions.

---

## Text Input

- **required**: Is this field required?
- **placeholder**: What is the placeholder text?
- **limit**: Maximum character count? (write "none" if unlimited)
- **multiline**: Is multi-line input (textarea) needed?
- **pattern**: Is there a format validation? (e.g. email, phone number, URL, etc.)
- **disabled**: Is there a disabled state? What triggers it?

---

## Number Input

- **required**: Is this field required?
- **min**: Minimum value?
- **max**: Maximum value?
- **step**: Step increment? (default 1)
- **precision**: How many decimal places to keep?
- **unit**: Should a unit be displayed? (e.g. px, %, s)

---

## Select (Dropdown)

- **required**: Is this field required?
- **multiple**: Does it support multi-selection?
- **searchable**: Can the options be searched/filtered?
- **clearable**: Can the selected value be cleared?
- **options**: Where do the options come from? (fixed list / dynamic API / user-defined)
- **defaultValue**: Is there a default selected option?

---

## Checkbox

- **required**: Must at least one option be selected?
- **options**: What are the options?
- **defaultChecked**: Which options are checked by default?

---

## Radio

- **required**: Must one option be selected?
- **options**: What are the options?
- **defaultValue**: Which option is selected by default?

---

## Slider

- **min**: Minimum value?
- **max**: Maximum value?
- **step**: Step increment?
- **range**: Is it a range selector (dual handles)?
- **showValue**: Should the current value be displayed in real time?
- **unit**: Should a unit label be shown?

---

## Date / Time Picker

- **required**: Is this field required?
- **type**: Selection type? (date / time / datetime / date-range)
- **min**: Earliest selectable date/time?
- **max**: Latest selectable date/time?
- **format**: Display format? (e.g. YYYY-MM-DD / HH:mm)
- **defaultValue**: Is there a default value? (e.g. current time)

---

## File Upload

- **required**: Must a file be uploaded?
- **accept**: Supported file types? (e.g. `.jpg,.png` / `.pdf` / `image/*`)
- **multiple**: Does it support uploading multiple files?
- **maxSize**: Maximum size per file? (e.g. 5MB)
- **maxCount**: Maximum number of files allowed?
- **preview**: Is a preview needed after upload?

---

## Switch / Toggle

- **defaultValue**: Default state — on or off?
- **labelOn**: Label text when turned on?
- **labelOff**: Label text when turned off?
- **disabled**: Is there a disabled state?

---

## Common Fields (applicable to all controls)

- **label**: What is the control's label text?
- **helpText**: Is helper/description text needed?
- **errorMessage**: What is the error message shown on validation failure?
- **disabled**: Is there a disabled logic? What triggers it?
- **visible**: Is there a show/hide logic? What triggers it?
