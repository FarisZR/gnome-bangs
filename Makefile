EXTENSION_UUID = bangs-search@suvan
EXTENSION_DIR = ~/.local/share/gnome-shell/extensions/$(EXTENSION_UUID)

.PHONY: all install uninstall compile-schemas clean test

all: compile-schemas install

install: compile-schemas
	@echo "Installing extension..."
	mkdir -p $(EXTENSION_DIR)
	cp extension.js $(EXTENSION_DIR)/
	cp prefs.js $(EXTENSION_DIR)/
	cp metadata.json $(EXTENSION_DIR)/
	cp bang.png $(EXTENSION_DIR)/
	mkdir -p $(EXTENSION_DIR)/schemas
	cp schemas/*.xml $(EXTENSION_DIR)/schemas/
	glib-compile-schemas $(EXTENSION_DIR)/schemas
	@echo "Extension installed at $(EXTENSION_DIR)."
	@echo "Restart GNOME Shell or reload extensions to apply changes."

uninstall:
	@echo "Uninstalling extension..."
	rm -rf $(EXTENSION_DIR)
	@echo "Extension uninstalled."
	@echo "Restart GNOME Shell or reload extensions to apply changes."

compile-schemas:
	@echo "Compiling GSettings schemas..."
	glib-compile-schemas schemas/

test: compile-schemas
	@echo "Validating extension metadata..."
	@python3 -c "import json; from pathlib import Path; root = Path('.'); metadata = json.loads((root / 'metadata.json').read_text(encoding='utf-8')); required_fields = {'name', 'description', 'uuid', 'shell-version', 'url', 'settings-schema'}; missing_fields = sorted(required_fields - metadata.keys()); assert not missing_fields, 'Missing metadata fields: ' + ', '.join(missing_fields); shell_versions = metadata.get('shell-version', []); assert isinstance(shell_versions, list) and all(isinstance(version, str) for version in shell_versions), 'shell-version must be a JSON array of strings'; assert '49' in shell_versions, 'GNOME Shell 49 support is missing from metadata.json'; required_files = [root / 'extension.js', root / 'prefs.js', root / 'bang.png', root / 'schemas' / 'org.gnome.shell.extensions.bangs.gschema.xml']; missing_files = [str(path) for path in required_files if not path.exists()]; assert not missing_files, 'Missing required file(s): ' + ', '.join(missing_files); print('Metadata validation passed.')"

clean:
	@echo "Cleaning up compiled schemas..."
	rm -f schemas/gschemas.compiled
	@echo "Done."
