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


  integer(c_int64_t), target :: vulkan_instance = 0


contains

  subroutine vulkan_run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine vulkan_run


  subroutine init_vulkan()
    implicit none

    type(vk_application_info), pointer :: app_info
    type(vk_instance_create_info), pointer :: create_info
    ! const char **
    type(vec) :: required_extensions

    call create_glfw()

    call create_app_info(app_info)

    call create_required_extensions(required_extensions)

    call ensure_extensions_present(required_extensions)

    call create_create_info(create_info, app_info, required_extensions)

    call create_vulkan_instance(create_info)

    ! todo: deallocate any pointers inside.
    deallocate(app_info)
    deallocate(create_info)

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


  subroutine create_required_extensions(required_extensions)
    implicit none

    type(vec), intent(inout) :: required_extensions
    integer(c_int) :: glfw_extension_count
    type(c_ptr) :: c_glfw_extension_array_pointer
    character(len = :, kind = c_char), pointer :: temp, output
    type(c_ptr), dimension(:), pointer :: c_extension_name_pointer_array
    integer(c_int) :: i
    ! type(c_ptr), pointer :: raw_c_ptr

    print"(A)","[Vulkan]: Gathering required GLFW extensions."

    c_glfw_extension_array_pointer = glfw_get_required_instance_extensions(glfw_extension_count)

    ! Grabble the extension string pointers from C.
    temp => null()
    required_extensions = new_vec(sizeof(c_null_ptr), 0_8)

    call c_f_pointer(c_glfw_extension_array_pointer, c_extension_name_pointer_array, [glfw_extension_count])

    ! Shove all those char pointers into the vector's heap.
    do i = 1,glfw_extension_count
      temp => string_from_c(c_extension_name_pointer_array(i))
      allocate(character(len = len(temp)+1, kind = c_char) :: output)
      output = temp//achar(0)

      call required_extensions%push_back(c_loc(output))
    end do

    print"(A)","[Vulkan]: Creating required GLFW extensions."

    ! We need this for it to work in MoltenVK.
    allocate(character(len = len(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME), kind = c_char) :: output)
    output = VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME
    call required_extensions%push_back(c_loc(output))

    !? How to transfer out for a double check.
    ! do i = 1,int(required_extensions%size())
    !   call c_f_pointer(required_extensions%get(int(i, c_int64_t)), raw_c_ptr)
    !   temp => string_from_c(raw_c_ptr)
    !   ! print*,temp
    !   ! print*,len(temp)
    ! end do
  end subroutine create_required_extensions


  subroutine ensure_extensions_present(required_extensions)
    implicit none

    type(vec), intent(inout) :: required_extensions
    integer(c_int) :: result, extension_count
    type(vec) :: available_extensions_array
    type(vk_extension_properties) :: blank
    integer(c_int) :: i, j, k, prop_length
    type(c_ptr), pointer :: raw_c_ptr
    type(vk_extension_properties), pointer :: extension_properties
    character(len = :, kind = c_char), pointer :: temp_string_pointer
    character(len = :, kind = c_char), allocatable :: temp
    logical(c_bool) :: found


    print"(A)","[Vulkan]: Gathering available extensions."

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, c_null_ptr)

    if (result /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to enumrate instance extension properties. Error code ["//int_to_string(result)//"]"
    end if

    available_extensions_array = new_vec(sizeof(blank), int(extension_count, c_int64_t))
    call available_extensions_array%resize(int(extension_count, c_int64_t), blank)

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, available_extensions_array%get(1_8))

    print"(A)","[Vulkan]: Ensuring required extensions are present."

    ! Iterate all required extensions.

    do j = 1,int(required_extensions%size())

      found = .false.

      call c_f_pointer(required_extensions%get(int(j, c_int64_t)), raw_c_ptr)
      temp_string_pointer => string_from_c(raw_c_ptr)

      ! Iterate all available extensions.
      do i = 1,int(extension_count)

        ! Transfer the VkExtensionProperties pointer into Fortran.
        call c_f_pointer(available_extensions_array%get(int(i, c_int64_t)), extension_properties)

        ! Find the length of the character array.
        do k = 1,VK_MAX_EXTENSION_NAME_SIZE
          if (extension_properties%extension_name(k) == achar(0)) then
            prop_length = k - 1
            exit
          end if
        end do

        ! Now copy it into a string.
        allocate(character(len = prop_length, kind = c_char) :: temp)

        do k = 1,prop_length
          temp(k:k) = extension_properties%extension_name(k)
        end do

        ! And check if the strings are equal.
        if (temp_string_pointer == temp) then
          found = .true.
          deallocate(temp)
          exit
        end if

        deallocate(temp)
      end do

      ! We can't continue if a required extensions isn't present.
      if (found) then
        print"(A)","[Vulkan]: Found required extension ["//temp_string_pointer//"]"
      else
        error stop "[Vulkan] Error: Could not find required extension ["//temp_string_pointer//"]"
      end if
    end do

    print"(A)","[Vulkan]: All required extensions are present."
  end subroutine ensure_extensions_present


  subroutine create_create_info(create_info, app_info, required_extensions)
    implicit none

    type(vk_instance_create_info), intent(inout), pointer :: create_info
    type(vk_application_info), intent(in), pointer :: app_info
    type(vec), intent(inout) :: required_extensions

    print"(A)","[Vulkan]: Creating create info."

    allocate(create_info)

    create_info%flags = xor(create_info%flags, VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR)

    create_info%s_type = VK_STRUCTURE_TYPE%INSTANCE_CREATE_INFO
    create_info%p_application_info = c_loc(app_info)
    create_info%enabled_extension_count = int(required_extensions%size())
    !? Note: This basically turns the vector into a pointer array.
    create_info%pp_enabled_extension_names = required_extensions%get(1_8)

    create_info%enabled_layer_count = 0
  end subroutine create_create_info


  subroutine create_vulkan_instance(create_info)
    implicit none

    type(vk_instance_create_info), intent(in), target :: create_info
    integer(c_int) :: result

    print"(A)", "[Vulkan]: Creating instance."

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

    ! do while(.not. glfw_window_should_close())
    !   call glfw_poll_events()
    ! end do

  end subroutine main_loop

  subroutine clean_up()
    implicit none

    print"(A)","[Vulkan]: Destroying instance."

    ! call forvk_destroy_pointer_instance(vulkan_instance)

    call glfw_destroy_window()

    call glfw_terminate()
  end subroutine clean_up


end module vulkan_driver
