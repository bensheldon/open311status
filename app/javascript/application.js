import { Application } from 'stimulus';

import CitiesController from './controllers/cities_controller';

window.Stimulus = Application.start();
Stimulus.register('cities', CitiesController);
