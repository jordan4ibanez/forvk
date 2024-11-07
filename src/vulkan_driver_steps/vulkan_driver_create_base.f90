module vulkan_driver_create_base
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: forvulkan_parameters
  use :: forvulkan
  implicit none


contains


  subroutine create_glfw()
    implicit none

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    ! call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_FALSE)

    if (.not. glfw_create_window(500, 500, "forvulkan")) then
      error stop "[Vulkan]: Failed to create window."
    end if
  end subroutine create_glfw


  subroutine create_app_info(app_info)
    implicit none

    type(vk_application_info), intent(inout), pointer :: app_info
    character(len = :, kind = c_char), pointer :: app_name, engine_name

    print"(A)","[Vulkan]: Creating app info."

    allocate(app_info)

    app_info%s_type = VK_STRUCTURE_TYPE%APPLICATION_INFO

    ! todo: this will need a bit of finesse in the future.
    allocate(character(len = 10, kind = c_char) :: app_name)
    app_name = "ForVulkan"//achar(0)

    app_info%p_application_name = c_loc(app_name)
    app_info%application_version = vk_make_api_version(0,1,0,0)

    ! todo: this will need a bit of finesse in the future.
    allocate(character(len = 8, kind = c_char) :: engine_name)
    engine_name = "Formine"//achar(0)

    app_info%p_engine_name = c_loc(engine_name)
    app_info%engine_version = vk_make_api_version(0,1,0,0)
    app_info%api_version = VK_API_VERSION_1_0
  end subroutine create_app_info


end module vulkan_driver_create_base
