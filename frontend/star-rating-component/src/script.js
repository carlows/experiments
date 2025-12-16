Stimulus.register(
  "stars",
  class extends Controller {
    static targets = ["star"];

    select(event) {
      this.starTargets.forEach((target) =>
        target.classList.remove("star-active"),
      );

      let current = event.currentTarget;
      while (current) {
        current.classList.add("star-active");
        current = current.nextElementSibling;
      }
    }

    connect() {
      console.log("Hello World!");
    }
  },
);
