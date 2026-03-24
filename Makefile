# Makefile for Gini Mobile iOS
# Usage: make lint scheme=<scheme_name>

# Default configuration
WORKSPACE := GiniMobile.xcworkspace
DESTINATION := "platform=iOS Simulator,id=dvtdevice-DVTiOSDeviceSimulatorPlaceholder-iphonesimulator:placeholder"
CONFIGURATION := Debug

# Color output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Scheme validation
ifeq ($(scheme),)
SCHEME_ERROR := true
else
SCHEME := $(scheme)
endif

.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)Gini Mobile iOS - Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make lint scheme=<scheme_name>   - Validate compilation for a specific scheme"
	@echo "  make list-schemes                - List all available schemes"
	@echo "  make clean                       - Clean build artifacts"
	@echo ""
	@echo "$(YELLOW)Available schemes:$(NC)"
	@xcodebuild -list -workspace $(WORKSPACE) 2>/dev/null | grep -A 100 "Schemes:" | grep "^        " | sed 's/^        /  - /'
	@echo ""
	@echo "$(YELLOW)Example:$(NC)"
	@echo "  make lint scheme=GiniBankSDK"
	@echo "  make lint scheme=GiniCaptureSDK"

.PHONY: list-schemes
list-schemes: ## List all available Xcode schemes
	@echo "$(BLUE)Available schemes in $(WORKSPACE):$(NC)"
	@xcodebuild -list -workspace $(WORKSPACE) 2>/dev/null | grep -A 100 "Schemes:" | grep "^        " | sed 's/^        /  - /'

.PHONY: lint
lint: ## Lint/validate compilation for a specific scheme (requires scheme parameter)
	bundle exec fastlane build_scheme target:"$(SCHEME)" destination:"platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2"


.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@xcodebuild clean \
		-workspace $(WORKSPACE) \
		-quiet 2>/dev/null || true
	@rm -rf build/
	@rm -rf DerivedData/
	@rm -f /tmp/xcodebuild.log
	@echo "$(GREEN)✓ Clean complete$(NC)"

.PHONY: lint-all-main
lint-all-main: ## Lint all main SDK schemes (GiniBankSDK, GiniCaptureSDK, GiniHealthSDK, GiniMerchantSDK)
	@echo "$(BLUE)======================================$(NC)"
	@echo "$(BLUE)Linting all main SDK schemes$(NC)"
	@echo "$(BLUE)======================================$(NC)"
	@$(MAKE) lint scheme=GiniBankSDK
	@$(MAKE) lint scheme=GiniCaptureSDK
	@$(MAKE) lint scheme=GiniHealthSDK
	@$(MAKE) lint scheme=GiniMerchantSDK
	@echo ""
	@echo "$(GREEN)✓ All main SDKs validated successfully$(NC)"

# Default target
.DEFAULT_GOAL := help
