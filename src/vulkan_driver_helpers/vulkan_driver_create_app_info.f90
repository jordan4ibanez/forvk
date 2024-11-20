module vulkan_driver_create_app_info
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_app_info(app_info)
    implicit none

    type(vk_application_info), intent(inout) :: app_info
    character(len = :, kind = c_char), pointer :: app_name, engine_name

    print"(A)","[Vulkan]: Creating app info."

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


end module vulkan_driver_create_app_info
