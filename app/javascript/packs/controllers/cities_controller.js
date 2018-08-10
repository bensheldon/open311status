import ActionCable from 'actioncable';
import { Controller } from "stimulus";

const cable = ActionCable.createConsumer();

export default class extends Controller {
  static targets = ["city"];

  connect() {
    this.cityTargets.forEach((cityEl) => {
      this.renderSparkline(cityEl);
    });

    cable.subscriptions.create('CitiesChannel', {
      received: (data) => {
        const cityEl = this.cityTargets.find(cityEl => {
          return cityEl.getAttribute('data-city-id') == data.city_id;
        });

        cityEl.innerHTML = data.city_html;
        this.renderSparkline(cityEl);
      }
    });
  }

  renderSparkline(cityEl) {
    $(cityEl).find(".sparkline").each((index, element) => {
      const data = $(element).attr('data-values').split(",");

      $(element).sparkline(data, {
        chartRangeMin: 0,
        fillColor: "#ddf2fb",
        height: "20px",
        lineColor: "#518fc9",
        lineWidth: 1,
        minSpotColor: "#0b810b",
        maxSpotColor: "#c10202",
        spotColor: false,
        spotRadius: 2, width: "150px"
      });
    });
  }
}