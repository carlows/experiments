Stimulus.register(
  "calendar",
  class CalendarComponent extends Controller {
    static targets = ["day", "body", "month"];
    static values = {
      currentDate: String,
    };

    connect() {
      const currentDate = new Date();
      this.updateMonth(currentDate);
      this.renderDays();
    }

    renderDays() {
      const currentDate = new Date(this.currentDateValue);
      const year = currentDate.getFullYear();
      const month = currentDate.getMonth();
      const days = this.getPaddedDaysInMonth(year, month);

      this.bodyTarget.replaceChildren();

      days.forEach((day) => {

        const template = this.dayTarget.content.cloneNode(true);
        const element = template.querySelector(".day");
        element.textContent = day.date.getDate();

        if (day.type !== "") {
          element.classList.add(day.type);
        }

        this.bodyTarget.appendChild(template);
      });
    }

    updateMonth(date) {
      const currentYear = date.getFullYear();
      const currentMonth = date.getMonth();
      this.currentDateValue = `${currentYear}-${String(currentMonth + 1).padStart(2, "0")}-01`;

      this.monthTarget.textContent = date.toLocaleString("default", {
        month: "long",
        year: "numeric",
      });
    }

    getDaysInMonth(year, month) {
      const daysInMonth = new Date(year, month + 1, 0).getDate();
      const currentDate = new Date();

      const days = [];
      for (let day = 1; day <= daysInMonth; day++) {
        days.push({
          date: new Date(year, month, day),
          type: currentDate.getDate() === day ? "day-today" : "",
        });
      }

      return days;
    }

    previous() {
      const currentDate = new Date(this.currentDateValue);
      currentDate.setMonth(currentDate.getMonth() - 1);
      this.updateMonth(currentDate);
      this.renderDays();
    }

    next() {
      const currentDate = new Date(this.currentDateValue);
      currentDate.setMonth(currentDate.getMonth() + 1);
      this.updateMonth(currentDate);
      this.renderDays();
    }

    getPaddedDaysInMonth(year, month) {
      const daysInMonth = this.getDaysInMonth(year, month);

      const firstDayOfMonth = new Date(year, month, 1);
      const firstDayOfWeek = firstDayOfMonth.getDay();
      const daysToAdd = firstDayOfWeek - 1;
      
      const daysToPrepend = [];
      for (let i = daysToAdd; i > 0; i--) {
        const day = new Date(year, month, firstDayOfMonth.getDate());
        day.setDate(day.getDate() - i);

        daysToPrepend.push({
          date: day,
          type: "day-outside",
        });
      }
      daysInMonth.unshift(...daysToPrepend);

      const lastDayOfMonth = new Date(year, month + 1, 0);
      const lastDayOfWeek = lastDayOfMonth.getDay();
      const availableDaysToAppend = 35 - daysInMonth.length;
      const remainingDaysToAppend = 7 - lastDayOfWeek;
      const daysToAppend = Math.min(availableDaysToAppend, remainingDaysToAppend);

      for (let i = 0; i < daysToAppend; i++) {
        daysInMonth.push({
          date: new Date(year, month, i + 1),
          type: "day-outside",
        });
      }

      return daysInMonth;
    }
  },
);

