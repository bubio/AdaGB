// The Ada main controls this bridge's lifecycle and all GUI widgets.
#include <SDL.h>
#include "imgui.h"
#include "imgui_impl_sdl2.h"
#include "imgui_impl_sdlrenderer2.h"

namespace {
SDL_Window* window = nullptr;
SDL_Renderer* renderer = nullptr;
bool platform_ready = false;
bool renderer_ready = false;
bool sdl_ready = false;
}

extern "C" void bridge_shutdown()
{
    if (renderer_ready) ImGui_ImplSDLRenderer2_Shutdown();
    if (platform_ready) ImGui_ImplSDL2_Shutdown();
    renderer_ready = platform_ready = false;
    if (renderer) SDL_DestroyRenderer(renderer);
    if (window) SDL_DestroyWindow(window);
    renderer = nullptr;
    window = nullptr;
    if (sdl_ready) SDL_Quit();
    sdl_ready = false;
}

extern "C" int bridge_init()
{
    IMGUI_CHECKVERSION();
    if (SDL_Init(SDL_INIT_VIDEO) != 0) return 0;
    sdl_ready = true;
    window = SDL_CreateWindow("AdaGB",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 960, 640,
        SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
    if (!window) return 0;
    renderer = SDL_CreateRenderer(window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!renderer) return 0;
    ImGui::GetIO().IniFilename = nullptr;
    ImGui::GetIO().ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    ImGui::StyleColorsDark();
    platform_ready = ImGui_ImplSDL2_InitForSDLRenderer(window, renderer);
    if (!platform_ready) return 0;
    renderer_ready = ImGui_ImplSDLRenderer2_Init(renderer);
    return renderer_ready ? 1 : 0;
}

extern "C" int bridge_poll()
{
    SDL_Event event;
    bool running = true;
    while (SDL_PollEvent(&event)) {
        ImGui_ImplSDL2_ProcessEvent(&event);
        if (event.type == SDL_QUIT ||
            (event.type == SDL_WINDOWEVENT &&
             event.window.event == SDL_WINDOWEVENT_CLOSE &&
             event.window.windowID == SDL_GetWindowID(window))) running = false;
    }
    return running ? 1 : 0;
}

extern "C" void bridge_new_frame()
{
    ImGui_ImplSDLRenderer2_NewFrame();
    ImGui_ImplSDL2_NewFrame();
}

extern "C" int bridge_present()
{
    const ImVec2 scale = ImGui::GetIO().DisplayFramebufferScale;
    if (SDL_RenderSetScale(renderer, scale.x, scale.y) != 0 ||
        SDL_SetRenderDrawColor(renderer, 28, 32, 40, 255) != 0 ||
        SDL_RenderClear(renderer) != 0) return 0;
    ImGui_ImplSDLRenderer2_RenderDrawData(ImGui::GetDrawData(), renderer);
    SDL_RenderPresent(renderer);
    return 1;
}

extern "C" const char* bridge_error() { return SDL_GetError(); }
