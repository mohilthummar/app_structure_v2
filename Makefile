# ============================
# FLUTTER PROJECT COMMANDS
# ============================

# ============================
# Color codes
# ============================

GREEN  = \033[0;32m
YELLOW = \033[1;33m
BLUE   = \033[0;34m
RED    = \033[0;31m
CYAN   = \033[0;36m
RESET  = \033[0m

# Package name — change this to your app's package name
PACKAGE = com.example.app_structure

# ============================
# HELP
# ============================

.DEFAULT_GOAL := help

help: ## Show all available commands
	@echo ""
	@echo "$(BLUE)Available Commands:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-22s$(RESET) %s\n", $$1, $$2}' \
		| sort
	@echo ""

# ============================
# BUILD
# ============================

build-apk: ## Build release APK
	@echo "$(GREEN)Building release APK...$(RESET)"
	flutter build apk --release

build-apk-split: ## Build release APK split by ABI (smaller per device)
	@echo "$(GREEN)Building split APK...$(RESET)"
	flutter build apk --split-per-abi

build-ios: ## Build release iOS
	@echo "$(GREEN)Building iOS...$(RESET)"
	flutter build ios --release

build-bundle: ## Build AAB for Play Store
	@echo "$(GREEN)Building AppBundle...$(RESET)"
	flutter build appbundle --release

build-debug: ## Build debug APK
	@echo "$(GREEN)Building debug APK...$(RESET)"
	flutter build apk --debug

build-profile: ## Build profile APK (for performance testing)
	@echo "$(GREEN)Building profile APK...$(RESET)"
	flutter build apk --profile

build-web: ## Build web app
	@echo "$(GREEN)Building web...$(RESET)"
	flutter build web --release

# ============================
# RUN
# ============================
# Environment is set in main.dart via AppEnvironment.setEnvironment()
# Change EnvironmentType in main.dart to switch environments.

run: ## Run app in debug mode
	@echo "$(BLUE)Running debug mode...$(RESET)"
	flutter run --debug

run-release: ## Run app in release mode
	@echo "$(BLUE)Running release mode...$(RESET)"
	flutter run --release

run-profile: ## Run app in profile mode (for performance testing)
	@echo "$(BLUE)Running profile mode...$(RESET)"
	flutter run --profile

# ============================
# DEVICE
# ============================

devices: ## List connected devices
	@echo "$(BLUE)Connected devices:$(RESET)"
	@flutter devices

uninstall: ## Uninstall app from connected Android device
	@echo "$(RED)Uninstalling $(PACKAGE)...$(RESET)"
	adb uninstall $(PACKAGE)

clear-data: ## Clear app data on Android (keeps app installed)
	@echo "$(YELLOW)Clearing app data...$(RESET)"
	adb shell pm clear $(PACKAGE)

logs: ## View Flutter logs (Ctrl+C to exit)
	@echo "$(BLUE)Viewing Flutter logs...$(RESET)"
	flutter logs

# ============================
# CODE QUALITY
# ============================

format: ## Format all Dart code
	@echo "$(BLUE)Formatting code...$(RESET)"
	dart format .

format-check: ## Check formatting without changing files
	@echo "$(BLUE)Checking code format...$(RESET)"
	dart format --set-exit-if-changed .

analyze: ## Run static analysis (lint checks)
	@echo "$(YELLOW)Analyzing code...$(RESET)"
	flutter analyze

lint: format analyze ## Format code + run analysis
	@echo "$(GREEN)Lint complete.$(RESET)"

fix: ## Auto-fix lint issues where possible
	@echo "$(BLUE)Applying auto-fixes...$(RESET)"
	dart fix --apply

fix-dry: ## Preview auto-fixes without applying
	@echo "$(BLUE)Previewing fixes...$(RESET)"
	dart fix --dry-run

# ============================
# TEST
# ============================

test: ## Run all tests
	@echo "$(YELLOW)Running tests...$(RESET)"
	flutter test

test-v: ## Run all tests with verbose output
	@echo "$(YELLOW)Running tests (verbose)...$(RESET)"
	flutter test --reporter expanded

test-coverage: ## Run tests and generate coverage report
	@echo "$(YELLOW)Running tests with coverage...$(RESET)"
	flutter test --coverage
	@echo "$(GREEN)Coverage report: coverage/lcov.info$(RESET)"

test-file: ## Run a single test file (usage: make test-file FILE=test/widget_test.dart)
	@echo "$(YELLOW)Running $(FILE)...$(RESET)"
	flutter test $(FILE)

# ============================
# ENVIRONMENT
# ============================
# Copy .env.example to .env and fill in values. .env is gitignored.

env-setup: ## Copy .env.example to .env (if .env missing)
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)Created .env from .env.example. Edit .env with your values.$(RESET)"; \
	else \
		echo "$(YELLOW).env already exists.$(RESET)"; \
	fi

# ============================
# MAINTENANCE
# ============================

clean: ## Clean build artifacts
	@echo "$(YELLOW)Cleaning project...$(RESET)"
	flutter clean

get: ## Get all dependencies
	@echo "$(BLUE)Getting packages...$(RESET)"
	flutter pub get

reset: ## Clean + get packages (fresh start)
	@echo "$(YELLOW)Resetting project...$(RESET)"
	flutter clean
	flutter pub get

hard-clean: ## Deep clean (Flutter + Gradle + CocoaPods)
	@echo "$(YELLOW)Deep cleaning...$(RESET)"
	flutter clean
	@if [ -d "android" ]; then \
		echo "$(YELLOW)Cleaning Gradle...$(RESET)"; \
		cd android && ./gradlew clean 2>/dev/null; cd ..; \
	fi
	@if [ -d "ios" ]; then \
		echo "$(YELLOW)Cleaning CocoaPods...$(RESET)"; \
		cd ios && rm -rf Pods Podfile.lock 2>/dev/null; cd ..; \
	fi
	flutter pub get
	@if [ -d "ios" ]; then \
		echo "$(YELLOW)Installing pods...$(RESET)"; \
		cd ios && pod install 2>/dev/null; cd ..; \
	fi
	@echo "$(GREEN)Deep clean complete.$(RESET)"

upgrade: ## Upgrade all dependencies to latest compatible versions
	@echo "$(BLUE)Upgrading dependencies...$(RESET)"
	flutter pub upgrade

outdated: ## Check for outdated packages
	@echo "$(YELLOW)Checking outdated packages...$(RESET)"
	flutter pub outdated

deps: ## Show dependency tree
	@echo "$(BLUE)Dependency tree:$(RESET)"
	flutter pub deps

# ============================
# INFO
# ============================

doctor: ## Run Flutter doctor
	@echo "$(BLUE)Running Flutter doctor...$(RESET)"
	flutter doctor

doctor-v: ## Run Flutter doctor (verbose)
	@echo "$(BLUE)Running Flutter doctor (verbose)...$(RESET)"
	flutter doctor -v

size: ## Analyze APK size
	@echo "$(BLUE)Analyzing app size...$(RESET)"
	flutter build apk --release --analyze-size

info: ## Show Flutter/Dart/project version info
	@echo "$(CYAN)Flutter:$(RESET)" && flutter --version
	@echo ""
	@echo "$(CYAN)Dart:$(RESET)" && dart --version
	@echo ""
	@echo "$(CYAN)Project:$(RESET)" && head -6 pubspec.yaml

# ============================
# GENERATION (for future use)
# ============================

# build-runner: ## Run build_runner (generates .g.dart, .freezed.dart)
# 	@echo "$(BLUE)Running build_runner...$(RESET)"
# 	dart run build_runner build --delete-conflicting-outputs

# watch: ## Watch build_runner (auto-regenerates on file changes)
# 	@echo "$(BLUE)Watching build_runner...$(RESET)"
# 	dart run build_runner watch --delete-conflicting-outputs

# icons: ## Generate app icons (requires flutter_launcher_icons)
# 	@echo "$(BLUE)Generating app icons...$(RESET)"
# 	dart run flutter_launcher_icons

# splash: ## Generate native splash screen (requires flutter_native_splash)
# 	@echo "$(BLUE)Generating splash screen...$(RESET)"
# 	dart run flutter_native_splash:create

.PHONY: help build-apk build-apk-split build-ios build-bundle build-debug build-profile build-web \
	run run-release run-profile devices uninstall clear-data logs \
	env-setup \
	format format-check analyze lint fix fix-dry \
	test test-v test-coverage test-file \
	clean get reset hard-clean upgrade outdated deps \
	doctor doctor-v size info
