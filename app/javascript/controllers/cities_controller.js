import { createConsumer } from "@rails/actioncable"
import { Controller } from "@hotwired/stimulus"
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler } from "chart.js"

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler)

const cable = createConsumer()

export default class extends Controller {
  static targets = ["city"]

  connect() {
    this.charts = []
    this.cityTargets.forEach(el => this.renderSparkline(el))

    cable.subscriptions.create("CitiesChannel", {
      received: (data) => {
        const cityEl = this.cityTargets.find(el => el.getAttribute("data-city-id") === data.city_id)
        cityEl.innerHTML = data.city_html
        this.renderSparkline(cityEl)
      },
    })
  }

  disconnect() {
    this.charts.forEach(c => c.destroy())
    this.charts = []
  }

  renderSparkline(cityEl) {
    cityEl.querySelectorAll(".sparkline").forEach((element) => {
      const values = element.getAttribute("data-values").split(",").map(Number)
      const canvas = document.createElement("canvas")
      canvas.width = 150
      canvas.height = 20
      element.innerHTML = ""
      element.appendChild(canvas)

      const minVal = Math.min(...values)
      const maxVal = Math.max(...values)
      const minIdx = values.lastIndexOf(minVal)
      const maxIdx = values.lastIndexOf(maxVal)

      const pointColors = values.map((_, i) => {
        if (i === maxIdx) return "#c10202"
        if (i === minIdx) return "#0b810b"
        return "transparent"
      })
      const pointRadii = values.map((_, i) => (i === minIdx || i === maxIdx) ? 2 : 0)

      this.charts.push(new Chart(canvas, {
        type: "line",
        data: {
          labels: values.map((_, i) => i),
          datasets: [{
            data: values,
            borderColor: "#518fc9",
            borderWidth: 1,
            backgroundColor: "#ddf2fb",
            fill: true,
            pointBackgroundColor: pointColors,
            pointRadius: pointRadii,
            pointHoverRadius: 0,
            tension: 0,
          }],
        },
        options: {
          responsive: false,
          animation: false,
          plugins: { legend: { display: false }, tooltip: { enabled: false } },
          scales: { x: { display: false }, y: { display: false, min: 0 } },
        },
      }))
    })
  }
}
