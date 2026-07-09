# Test Fixture PDFs

These files are required to run UI tests locally.
They are NOT committed to the repo — place them here manually.

Required files:
- skonto_valid.pdf
- skonto_past.pdf
- sepa_invoice.pdf
- sepa_already_paid.pdf
- sepa_due_date.pdf
- cx_invoice.pdf
- cx_no_results_invoice.pdf
- cx_invoice_multi_page.pdf
- cx_invoice_page2.pdf
- return_asistant.pdf
- test_image.pdf

After placing the files here, run once:
  bash BankSDK/GiniBankSDKExample/scripts/copy_test_fixtures.sh

Files will appear in the simulator under:
  Files app → On My iPhone → GiniBankSDKExample
