import * as process from 'process';
import { config } from 'dotenv';

config();

export const Envs = {
  app: {
    port: process.env.API_PORT ?? 3000,
  },
};
