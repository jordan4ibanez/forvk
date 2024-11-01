module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: forvk
  use :: forvk_parameters
  use :: glfw
  use :: string_f90
  use :: vector
  implicit none


  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.


  type(c_ptr) :: vulkan_instance = c_null_ptr


contains

  subroutine vulkan_run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine vulkan_run


  subroutine init_vulkan()
    implicit none

    integer(c_int), target :: glfw_extension_count
    ! const char **
    type(c_ptr) :: glfw_extensions_array_pointer
    type(vk_application_info), target :: app_info
    type(vk_instance_create_info), target :: create_info

    call create_glfw()

    call create_app_info(app_info)

    glfw_extensions_array_pointer = glfw_get_required_instance_extensions(glfw_extension_count)

    call create_create_info(create_info, app_info, glfw_extensions_array_pointer, glfw_extension_count)

    call create_vulkan_instance(create_info)

  end subroutine init_vulkan


  subroutine create_glfw()
    implicit none

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    ! call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_FALSE)

    if (.not. glfw_create_window(500, 500, "forvk")) then
      error stop "[Vulkan]: Failed to create window."
    end if
  end subroutine create_glfw


  subroutine create_app_info(app_info)
    implicit none

    character(len = :, kind = c_char), pointer :: app_name, engine_name

    type(vk_application_info), intent(inout), target :: app_info

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


  subroutine create_create_info(create_info, app_info, glfw_extensions, glfw_extension_count)
    implicit none

    type(vk_instance_create_info), intent(inout), target :: create_info
    type(vk_application_info), intent(in), target :: app_info
    type(c_ptr), intent(in), value :: glfw_extensions
    integer(c_int), intent(in), value :: glfw_extension_count
    ! type(vec) :: required_extensions
    ! character(len = 1, kind = c_char), pointer :: blank
    ! type(c_ptr), dimension(:), pointer :: c_glfw_extension_array_pointer

    ! blank => null()
    ! required_extensions = new_vec(sizeof(blank), 0_8)

    ! call c_f_pointer(glfw_extensions, c_glfw_extension_array_pointer, [glfw_extension_count])

    create_info%s_type = VK_STRUCTURE_TYPE%INSTANCE_CREATE_INFO
    create_info%p_application_info = c_loc(app_info)
    create_info%enabled_extension_count = glfw_extension_count
    create_info%pp_enabled_extension_names = glfw_extensions

    create_info%enabled_layer_count = 0
  end subroutine create_create_info


  subroutine create_vulkan_instance(create_info)
    implicit none

    type(vk_instance_create_info), intent(in), target :: create_info
    integer(c_int) :: result

    !? We must grab the raw data pointer from C because it could be
    !? different on different platforms.
    vulkan_instance = vk_grab_instance_pointer()

    result = vk_create_instance(c_loc(create_info), c_null_ptr, vulkan_instance)

    if (result /= VK_SUCCESS) then
      ! Shove driver check in.
      if (result == VK_ERROR_INCOMPATIBLE_DRIVER) then
        error stop "[Vulkan] Error: Failed to create Vulkan instance. Incompatible driver. Error code: ["//int_to_string(result)//"]"
      end if
      error stop "[Vulkan] Error: Failed to create Vulkan instance. Error code: ["//int_to_string(result)//"]"
    end if
  end subroutine create_vulkan_instance


!* MAIN LOOP. ====================================================================


  subroutine main_loop()
    implicit none

    do while(.not. glfw_window_should_close())
      call glfw_poll_events()
    end do

  end subroutine main_loop

  subroutine clean_up()
    implicit none

    call glfw_destroy_window()

    call glfw_terminate()
  end subroutine clean_up


end module vulkan_driver
