module forvk
  implicit none
  private

  public :: say_hello
contains
  subroutine say_hello
    print *, "Hello, forvk!"
  end subroutine say_hello
end module forvk
