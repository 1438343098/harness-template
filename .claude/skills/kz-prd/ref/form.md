---
name: form
description: 当 PRD 中涉及表单控件时使用，定义了各类表单控件（text input、number input、select、checkbox、radio、slider、date picker、file upload 等）需要向用户收集的具体需求细节
---

# 表单控件需求收集规范

## 概述

当遇到表单相关控件时，根据下方对应控件类型，逐一向用户提问补充细节。每个字段均以提问形式确认。

---

## Text Input（文本输入）

- **required**：是否必填？
- **placeholder**：占位符文案是什么？
- **limit**：最大字符数限制？（无限制则填 none）
- **multiline**：是否多行输入（textarea）？
- **pattern**：是否有格式校验？（如 email、手机号、URL 等）
- **disabled**：是否有禁用状态？触发条件？

---

## Number Input（数字输入）

- **required**：是否必填？
- **min**：最小值？
- **max**：最大值？
- **step**：步进值？（默认 1）
- **precision**：保留几位小数？
- **unit**：是否显示单位？（如 px、%、s）

---

## Select（下拉选择）

- **required**：是否必填？
- **multiple**：是否支持多选？
- **searchable**：是否可搜索筛选？
- **clearable**：是否可清空已选项？
- **options**：选项来源？（固定列表 / 动态接口 / 用户自定义）
- **defaultValue**：是否有默认选中项？

---

## Checkbox（复选框）

- **required**：是否至少需要选择一项？
- **options**：选项有哪些？
- **defaultChecked**：默认勾选哪些项？

---

## Radio（单选框）

- **required**：是否必须选择一项？
- **options**：选项有哪些？
- **defaultValue**：默认选中哪一项？

---

## Slider（滑块）

- **min**：最小值？
- **max**：最大值？
- **step**：步进值？
- **range**：是否为范围选择（双滑块）？
- **showValue**：是否实时显示当前值？
- **unit**：是否显示单位标注？

---

## Date / Time Picker（日期时间选择）

- **required**：是否必填？
- **type**：选择类型？（date / time / datetime / date-range）
- **min**：最早可选日期/时间？
- **max**：最晚可选日期/时间？
- **format**：显示格式？（如 YYYY-MM-DD / HH:mm）
- **defaultValue**：是否有默认值？（如当前时间）

---

## File Upload（文件上传）

- **required**：是否必须上传？
- **accept**：支持的文件类型？（如 `.jpg,.png` / `.pdf` / `image/*`）
- **multiple**：是否支持多文件上传？
- **maxSize**：单文件大小上限？（如 5MB）
- **maxCount**：最多上传几个文件？
- **preview**：上传后是否需要预览功能？

---

## Switch / Toggle（开关）

- **defaultValue**：默认开启还是关闭？
- **labelOn**：开启状态的文案？
- **labelOff**：关闭状态的文案？
- **disabled**：是否有禁用状态？

---

## 通用字段（所有控件适用）

- **label**：控件标签文案？
- **helpText**：是否需要帮助说明文字？
- **errorMessage**：校验失败时的错误提示文案？
- **disabled**：是否存在禁用逻辑？触发条件？
- **visible**：是否存在显示/隐藏逻辑？触发条件？
