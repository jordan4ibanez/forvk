module forvk
  use, intrinsic :: iso_c_binding
  implicit none


  private


  public :: say_hello


contains


  subroutine say_hello
    implicit none

    print *, "Hello, forvk!"
  end subroutine say_hello


end module forvk
