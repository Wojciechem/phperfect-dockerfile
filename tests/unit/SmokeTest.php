<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class SmokeTest extends TestCase
{
    public function testItIsActuallyPossibleToRunTests(): void
    {
        self::expectNotToPerformAssertions();
    }
}
