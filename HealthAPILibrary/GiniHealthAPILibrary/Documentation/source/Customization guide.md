Customization guide
=============================

The Gini Health SDK components can be customized either through the `GiniHealthConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

- [Generic components](#generic-components)
- [Payment Review screen](#payment-review-screen)


## Supporting dark mode

Some background and text colors use the `GiniColor` type with which you can set colors for dark and light modes. The text colors should also be set in contrast to the background colors.

## Generic components

##### 1. Gini Capture font

- Font &#8594;  `GiniHealthConfiguration.customFont`

## Payment Review screen

<br>
<center><img src="img/Customization guide/PaymentReview.PNG" height="500"/></center>
</br>

##### 1. Background color
- Background color &#8594; `GiniHealthConfiguration.paymentScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 2. Input fields container
- Background color &#8594; `GiniHealthConfiguration.inputFieldsContainerBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 3. Input field
- Background color &#8594; `GiniHealthConfiguration.paymentInputFieldBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Text color &#8594; `GiniHealthConfiguration.paymentInputFieldTextColor` using `GiniColor` with dark mode and light mode colors
- Font &#8594; `GiniHealthConfiguration.paymentInputFieldFont`
- Corner radius &#8594; `GiniHealthConfiguration.paymentInputFieldCornerRadius`
- Border width &#8594; `GiniHealthConfiguration.paymentInputFieldBorderWidth`

<br>
<center><img src="img/Customization guide/SelectionStyle.jpeg" height="500"/></center>
</br>
- Error selection style border color and error label text color &#8594; `GiniHealthConfiguration.paymentInputFieldErrorStyleColor` using `UIColor`
- Focus selection style border color &#8594; `GiniHealthConfiguration.paymentInputFieldSelectionStyleColor` using `UIColor`
- Focus selection style background color &#8594; `GiniHealthConfiguration.paymentInputFieldSelectionBackgroundColor` using `UIColor`
- Placeholder text color &#8594; `GiniHealthConfiguration.paymentInputFieldPlaceholderTextColor` using `GiniColor` with dark mode and light mode colors
- Placeholder font &#8594; `GiniHealthConfiguration.paymentInputFieldPlaceholderFont`
- Recipient placeholder text &#8594; <span style="color:#009EDF">*ginipaybusiness.reviewscreen.recipient.placeholder*</span> localized string
- IBAN placeholder text &#8594; <span style="color:#009EDF">*ginipaybusiness.reviewscreen.iban.placeholder*</span> localized string
- Amount placeholder text &#8594; <span style="color:#009EDF">*ginipaybusiness.reviewscreen.amount.placeholder*</span> localized string
- Purpose placeholder text &#8594; <span style="color:#009EDF">*ginipaybusiness.reviewscreen.usage.placeholder*</span> localized string

- Recipient error label text &#8594; <span style="color:#009EDF">*ginipaybusiness.errors.failed.recipient.non.empty.check*</span> localized string
- IBAN error label text &#8594; <span style="color:#009EDF">*ginipaybusiness.errors.failed.iban.non.empty.check*</span> localized string
- IBAN validation error label text &#8594; <span style="color:#009EDF">*ginipaybusiness.errors.failed.iban.validation.check*</span> localized string
- Amount error label text &#8594; <span style="color:#009EDF">*ginipaybusiness.errors.failed.amount.non.empty.check*</span> localized string
- Purpose error label text &#8594; <span style="color:#009EDF">*ginipaybusiness.errors.failed.purpose.non.empty.check*</span> localized string
- Default validation error label text &#8594; <span style="color:#009EDF">*ginipaybusiness.errors.failed.default.textfield.validation.check*</span> localized string

- Amount placeholder text &#8594; <span style="color:#009EDF">*ginipaybusiness.reviewscreen.amount.placeholder*</span> localized string
- Purpose placeholder text &#8594; <span style="color:#009EDF">*ginipaybusiness.reviewscreen.usage.placeholder*</span> localized string

##### 4. Pay button
- Background color &#8594; `GiniHealthConfiguration.payButtonBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Text color &#8594; `GiniHealthConfiguration.payButtonTextColor` using `GiniColor` with dark mode and light mode colors
- Font &#8594; `GiniHealthConfiguration.payButtonTextFont`
- Corner radius &#8594; `GiniHealthConfiguration.payButtonCornerRadius`

##### 5. Loading indicator
- Color &#8594; `GiniHealthConfiguration.loadingIndicatorColor` using `GiniColor` with dark mode and light mode colors
- Indicator Style &#8594; `GiniHealthConfiguration.loadingIndicatorStyle` using `UIActivityIndicatorView.Style` 
- Scale factor &#8594; `GiniHealthConfiguration.loadingIndicatorScale`