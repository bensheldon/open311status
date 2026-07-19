import { Controller } from "@hotwired/stimulus"
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Legend, Tooltip, Colors } from "chart.js"

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Legend, Tooltip, Colors)

export default class extends Controller {
  static values = { series: Array }

  connect() {
    const canvas = document.createElement("canvas")
    this.element.appendChild(canvas)

    const allLabels = [...new Set(
      this.seriesValue.flatMap(s => Object.keys(s.data))
    )].sort()

    const formatLabel = (t) => {
      const d = new Date(t)
      return `${d.getMonth() + 1}/${d.getDate()} ${String(d.getHours()).padStart(2, "0")}:00`
    }

    const datasets = this.seriesValue.map((series) => ({
      label: series.name,
      data: allLabels.map(t => series.data[t] ?? null),
      fill: false,
      tension: 0.1,
      spanGaps: true,
    }))

    this.chart = new Chart(canvas, {
      type: "line",
      data: { labels: allLabels.map(formatLabel), datasets },
      options: {
        responsive: true,
        scales: {
          x: { ticks: { maxRotation: 0, autoSkip: true, maxTicksLimit: 8 } },
          y: { beginAtZero: true },
        },
      },
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
