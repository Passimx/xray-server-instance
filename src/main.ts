import { NestFactory } from '@nestjs/core';
import { AppModule } from './modules/app.module';
import { Envs } from './common/envs/envs';
import { ValidationPipe } from '@nestjs/common';
import { logger } from './common/logger/logger';
import { version } from '../package.json';
import { usersInit } from './common/init/users.init';

async function bootstrap() {
  await usersInit();

  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      validateCustomDecorators: true,
      whitelist: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
      skipMissingProperties: false,
      validationError: {
        target: true,
        value: true,
      },
    }),
  );

  await app.listen(Envs.app.port);

  logger.info(
    `Server is running on url: ${await app.getUrl()} at ${Date()}. Version: '${version}'.`,
  );
}

bootstrap().catch((err) => logger.error(err));
