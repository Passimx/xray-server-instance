import { NestFactory } from '@nestjs/core';
import { AppModule } from './modules/app.module';
import { Envs } from './common/envs/envs';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(Envs.app.port);
}

bootstrap();
