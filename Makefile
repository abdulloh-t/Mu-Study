run:
	flutter run
clean:
	flutter clean
get:
	flutter pub get
ch:
	flutter run -d Chrome

apk:
	flutter build apk --release
	cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/mu_study.apk
	@echo "Built: build/app/outputs/flutter-apk/mu_study.apk"