# OpenClaw Synology Package Roadmap

## 1) Add an Actual Application Interface (like Download Manager or other Synology apps)
This creates a native-feeling DSM app window for managing OpenClaw, with admin/settings. It builds on the existing `dsmuidir="ui"` setup, using HTML/JS for the UI (no need for a full backend server — leverage OpenClaw's API via JS fetches).

- **Purpose**: Central hub for configuration, monitoring, and basic file management without leaving DSM. Embed the gateway dashboard as a tab for seamless access.
- **Tech Stack**: Pure client-side (HTML/CSS/JS) in `package/ui/`, with fetches to OpenClaw's API (`http://localhost:18789/...`). Store settings in local JSON files (e.g., `/var/packages/openclaw/var/settings.json`).
- **UI Layout**:
  - **Main Titlebar (Top)**: 
    - Left: Claw logo (from icons) + "OpenClaw Manager"
    - Right: Buttons for Refresh, Help (link to docs), and Logout/Close if needed.
    - Search bar for quick filtering (e.g., search agents or folders).
  - **Left-Hand Side Menu (Sidebar, ~20% width, collapsible on mobile/small windows)**:
    - **[Collapsible Section] Overview**:
      - [Menu Item]: Dashboard → Shows key stats (e.g., running agents, CPU usage, recent logs). Pull from OpenClaw API.
      - [Menu Item]: Status → Health checks, uptime, version info.
    - **[Collapsible Section] Files**:
      - [Menu Item]: Folders → Show list of local shared folders to manage (e.g., select which folders OpenClaw can access for storage/workspaces). Include add/remove, permissions settings.
      - [Menu Item]: Workspaces → List/manage OpenClaw workspaces (e.g., create new, set paths to shared folders).
      - [Menu Item]: Logs → View/download install/openclaw.log files.
    - **[Separator]**
    - [Menu Item]: Gateway Dashboard → Embeds the full OpenClaw gateway dashboard (http://localhost:18789/) in an iframe on the right side.
    - **[Collapsible Section] Settings**:
      - [Menu Item]: General → Basic config (e.g., port, bind mode). Edit and save to openclaw.json.
      - [Menu Item]: Agents → List/configure agents (pull from OpenClaw API).
      - [Menu Item]: Security → Manage tokens, origins, sandbox options (ties into point 2).
      - [Menu Item]: Updates → Check for OpenClaw updates, trigger npm update.
    - **[Collapsible Section] Advanced**:
      - [Menu Item]: API Access → Generate/view API keys for external integrations.
      - [Menu Item]: Backup/Restore → Export/import settings and workspaces.
  - **Right-Hand Side Content (Main Panel, ~80% width)**:
    - Dynamic content based on left menu selection.
    - Use tabs or sections for sub-views (e.g., in Folders: tab for "All Folders" vs "Permissions").
    - Include action buttons (e.g., Save, Apply, Cancel) at the bottom.
    - Responsive: On small windows, sidebar collapses to a hamburger menu.
- **Settings Storage**: All configs (e.g., selected folders, custom ports) stored in `/var/packages/openclaw/var/settings.json`. Load on app start via JS fetch (or localStorage for client-side prefs). Sync with OpenClaw's main config.json where needed.
- **Implementation Notes**:
  - Use DSM's CSS classes for native look (inspect other apps like File Station for selectors).
  - Embed gateway: `<iframe src="http://localhost:18789/" style="width:100%; height:100%; border:none;"></iframe>`.
  - Security: All API calls to localhost, no external exposure.
  - Testing: Add a debug mode toggle in settings to show raw API responses.

## 2) Investigate Sandboxing (e.g., chroot with Mapped Folders)
- **Purpose**: Isolate OpenClaw processes for security, limiting access to only approved shared folders.
- **Options to Explore**:
  - **Chroot**: Use DSM's chroot tools (if available) or custom script to jail the Node process. Map approved folders (from UI settings) into the chroot (e.g., bind-mount `/volume1/shared/folder` to `/sandbox/data`).
  - **Docker Integration**: If DSM supports it, run OpenClaw in a Docker container with volume mounts for shared folders. Easier than chroot, with built-in isolation.
  - **Namespace/SELinux**: Check if DSM kernel supports user namespaces or SELinux for lighter isolation without full container overhead.
  - **Implementation**: Add a "Sandbox Mode" toggle in UI Settings. When enabled, restart OpenClaw in the sandbox via service wrapper. Log sandbox events for auditing.
  - **Pros/Cons**: Chroot is lightweight but tricky to set up; Docker is robust but requires DSM Docker package.
  - **Next Steps**: Test feasibility on your DS920+ (e.g., run a test chroot script). If viable, integrate into openclawctl with config-driven mounts.
